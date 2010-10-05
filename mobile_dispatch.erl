%    -*- Erlang -*- 
%    File:	rest_appmod.erl
%    Author:	Nadia Mohedano Troyano
%
%  Adapted to SimpleBridge by etnt@redhoterlang.com
%

-module({{appid}}_dispatch).

-export([run/2]).

-include("{{appid}}.hrl").
-include_lib("yaws/include/yaws_api.hrl").

%%% @doc This is the routing table.
routes() ->
    [  {"/",         {{appid}}_web_index}
     , {"example",   {{appid}}_example_controller}
     , {"entry",     {{appid}}_web_entry}
     , {"about",     {{appid}}_web_about}
     , {"nitrogen",  {{appid}}_static_file}
     , {"js",        {{appid}}_static_file}
     , {"css",       {{appid}}_static_file}
     , {"images",    {{appid}}_static_file}
     , {"img",       {{appid}}_static_file}
     , {"themes",    {{appid}}_static_file}
    ].

run(Request, Response0) ->
    Method  = Request:request_method(),
    Path    = Request:path(),

    try 
        {Controller, CPath, ControllerPath} = parse_route(Path),
        Meth = clean_method(Method),
        Args = #controller{request      = Request, 
                           response     = Response0, 
                           cpath        = CPath, 
                           path         = ControllerPath, 
                           method       = Meth},
        Response = run_controller(Controller, Args),
        Response:build_response()

    catch
        throw:{ssi, SSI} ->
            SSI;

        throw:not_supported ->
            {{appid}}:build_response(Response0, 406,
                                  [{"Content-Type", "text/plain"}],
                                  "Not acceptable");

        throw:not_found ->
            {{appid}}:build_response(Response0, 404,
                                  [{"Content-Type", "text/plain"}],
                                  "Not Found")

    end.


run_controller(Controller, Args) ->
    try Controller:dispatch(Args)
    catch
	throw:bad_request ->
          {{appid}}:mk_response(Args#controller.response, 400,
                             [{"Content-Type", "text/plain"}],
                             "Bad Request");

	throw:bad_method ->
          {{appid}}:mk_response(Args#controller.response, 405,
                             [{"Content-Type", "text/plain"}],
                             "Bad Method");

        E:_ when E==error orelse E==exit ->
          {{appid}}:mk_response(Args#controller.response, 404,
                             [{"Content-Type", "text/plain"}],
                             "Not Found")
    end.

%%	{'EXIT', _} -> 
%%	    [{status, 404}, {content, "text/html", "Not Found"}];
%%	{Status, ContentType, Data} ->
%%	    [{status, Status}, {content, ContentType ++ ";" ++ ?CHARSET,
%%				Data}];
%%	{Status, ContentType, "no-cache", Data} ->
%%	    [{status, Status}, 
%%	     {content, ContentType ++ ";" ++ ?CHARSET, Data}, 
%%	     {header, {cache_control, "no-cache, must-revalidate"}}]; 
%%	{Status, ContentType, {LastModified, ETag}, Data} ->
%%	    [{status, Status}, 
%%	     {content, ContentType ++ ";" ++ ?CHARSET, Data}, 
%%	     {header, {cache_control, "no-cache, must-revalidate"}},
%%	     {header, "Last-Modified:" ++ LastModified},
%%	     {header, "ETag:" ++ ETag}];
%%	304 ->
%%	    [{status, 304}]
%%    end.


% Parses the path and returns {top_controller, rest}
parse_route(Path) when Path=="" orelse Path=="/" -> 
    return_controller("/", []);
parse_route(Path) ->
    CleanedPath = clean_path(Path),
    case string:tokens(CleanedPath, "/") of
	[]         -> return_controller("/", []);
	[Top|Rest] -> return_controller(Top, Rest)
    end.

return_controller(Top, Rest) ->
    case lists:keyfind(Top, 1, routes()) of
        {_,Controller} -> {Controller, Top, Rest};
        _              -> throw(not_found)
    end.

clean_path(Path) ->
    case string:str(Path, "?") of
	0 -> Path;
	N -> string:substr(Path, 1, N - 1)
    end.

clean_method(M) ->
    case M of
	'OPTIONS' -> get;
	_ -> list_to_atom(string:to_lower(atom_to_list(M)))
    end.
