%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.

%% @doc Callbacks for the polish application.

-module({{appid}}_inets).

-export([start_link/0, stop/0, do/1]).

-include_lib("nitrogen/include/wf.hrl").

-define(PORT, 8080).


start_link() ->
    inets:start(),
    {ok, Pid} =
        inets:start(httpd,
                    [{port, {{appid}}_deps:get_env(port,?PORT)}
                     ,{server_name,  hostname() }
                     ,{server_root, "."}
                     ,{document_root, {{appid}}_deps:get_env(doc_root,"./www")}
                     ,{modules, [?MODULE]}
                     ,{mime_types, [{"css",  "text/css"},
                                    {"js",   "text/javascript"},
                                    {"html", "text/html"}]}
                    ]),
    link(Pid),
    {ok, Pid}.

stop() ->
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

