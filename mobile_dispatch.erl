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


run(Request, Response) ->
    Headers = Request:headers(),
    Method  = Request:request_method(),
    Path    = Request:path(),
    case Path =:= "" orelse Path =:= "/" of
	true ->
	    {ssi, "/index.html", "%%", []};
	false ->
	    case parse_accept(Headers) of
		not_supported ->
                    {{appid}}:mk_response(Response, 406,
                                       [{"Content-Type", "text/plain"}],
                                       "Not acceptable");
		ContentType ->
    		    {Controller, ControllerPath} = parse_path(Path),
		    Meth = clean_method(Method),
		    Args = #controller{request      = Request, 
                                       response     = Response, 
                                       content_type = ContentType, 
                                       path         = ControllerPath, 
                                       method       = Meth},
		    run_controller(Controller, Args)
	    end
    end.

run_controller(Controller, Args) ->
    try
        Response = Controller:dispatch(Args),
        Response:build_response()
    catch
	throw:bad_request ->
          {{appid}}:mk_response(Args#controller.response, 400,
                             [{"Content-Type", "text/plain"}],
                             "Bad Request");

	throw:bad_method ->
          {{appid}}:mk_response(Args#controller.response, 405,
                             [{"Content-Type", "text/plain"}],
                             "Bad Method");

        _:_ ->
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


parse_accept(Headers) ->
    io:format("Headers=~p~n",[Headers]),
    try 
        {accept, Accept} = lists:keyfind(accept, 1, Headers),
        AcceptList = string:tokens(Accept, ","),
        case lists:member("*/*", AcceptList) of
            true  -> "application/xhtml+xml";
            false -> parse_accept(?SUPPORTED_MEDIA, AcceptList)
        end
    catch
        _:_ -> not_supported
    end.
            
 
parse_accept([Type | RestSupportedTypes], UserAcceptedTypes)->
    case lists:member(Type, UserAcceptedTypes) of
	true ->
	    Type;
	false ->
	    parse_accept(RestSupportedTypes, UserAcceptedTypes)
    end;
parse_accept([], _) ->
    not_supported.

% Parses the path and returns {top_controller, rest}
parse_path(Path) ->
    CleanedPath = clean_path(Path),
    case string:tokens(CleanedPath, "/") of
	[] ->
	    {index, no_path};
	[Top|Rest] ->
	    {list_to_atom("{{appid}}_"++ Top ++ "_controller"), Rest}
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
