%    -*- Erlang -*- 
%    File:	rest_appmod.erl
%    Author:	Nadia Mohedano Troyano
%
%  Adapted to SimpleBridge by etnt@redhoterlang.com
%

-module({{appid}}_example_controller).

-export([dispatch/1]).

-include("{{appid}}.hrl").
-include_lib("yaws/include/yaws_api.hrl").

dispatch(#controller{path = ""} = Args)    -> top(Args);
%dispatch(#controller{path = "new"} = Args) -> new(Args);
dispatch(_Args)                            -> erlang:error(bad_uri).


top(#controller{method       = get, 
                request      = Request, 
                response     = Response, 
                content_type = ContentType}) ->

    QueryString = Request:query_params(),
    %%Data = get_data(QueryString),
    %%Response = render(Data, ResContentType),
    Data = "<html><head></head><body>The Top Page</body></html>",
    {{appid}}:mk_response(Response, 200,
                       [{"Content-Type", ContentType}],
                       Data);

top(#controller{method       = post, 
                request      = Request, 
                response     = Response, 
                content_type = ResContentType}) ->

    Body =  Request:post_params(),
    Data = [], %% render:create(ResContentType),
    %% rest_cache:set_validation(Data), 
    {{appid}}:mk_response(Response, 200,
                       [{"Content-Type", "text/html"}],
                       Data);

top(#controller{method = delete}) ->
    throw(bad_method);

top(#controller{method = put}) ->
    throw(bad_method).

