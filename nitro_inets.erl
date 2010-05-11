%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.

%% @doc Callbacks for the polish application.

-module({{appid}}_inets).

-export([start_link/0, stop/0, do/1]).

-include_lib("nitrogen/include/wf.hrl").


%%% @doc This is the routing table.
routes() ->
    [{"/",            {{appid}}_web_index}
     , {"/login",     {{appid}}_web_login}
     , {"/logout",    {{appid}}_web_logout}
     , {"/auth",      {{appid}}_web_auth}
     , {"/ajax",      {{appid}}_web_ajax}
     , {"/nitrogen",  static_file}
     , {"/js",        static_file}
     , {"/css",       static_file}
    ].

start_link() ->
    inets:start(),
    {ok, Pid} =
        inets:start(httpd,
                    [{port, {{appid}}_deps:get_env(port, {{appid}}:default_port())}
                     ,{server_name,  {{appid}}_deps:get_env(hostname, {{appid}}:hostname())}
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
    httpd:stop_service({any, {{appid}}_deps:get_env(port, {{appid}}:default_port())}),
    ok.

do(Info) ->
    RequestBridge = simple_bridge:make_request(inets_request_bridge, Info),
    ResponseBridge = simple_bridge:make_response(inets_response_bridge, Info),
    nitrogen:init_request(RequestBridge, ResponseBridge),
    replace_route_handler(),
    nitrogen:run().

replace_route_handler() ->
    wf_handler:set_handler(named_route_handler, routes()).
