%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.

%% @doc Callbacks for the {{appid}} application.

-module({{appid}}_app).
-behaviour(application).

-export([start/2, stop/1, do/1]).

-include_lib("nitrogen/include/wf.hrl").

-define(PORT, 8080).


start(_, _) ->
    inets:start(),
    {ok, Pid} =
        inets:start(httpd,
                    [{port, ?PORT}
                     ,{server_name,  hostname() }
                     ,{server_root, "."}
                     ,{document_root, {{appid}}_deps:get_env(doc_root,"./www")}
                     ,{modules, [?MODULE]}
                     ,{mime_types, [{"css", "text/css"},
                                    {"js", "text/javascript"},
                                    {"html", "text/html"}]}
                    ]),
    link(Pid),
    {ok, Pid}.

stop(_) ->
    httpd:stop_service({any, ?PORT}),
    ok.

do(Info) ->
    RequestBridge = simple_bridge:make_request(inets_request_bridge, Info),
    ResponseBridge = simple_bridge:make_response(inets_response_bridge, Info),
    nitrogen:init_request(RequestBridge, ResponseBridge),
    nitrogen:run().

hostname() ->
    {ok,Host} = inet:gethostname(),
    Host.

