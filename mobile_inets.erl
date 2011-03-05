%% @author {{name}} {{email}}
%% @copyright YYYY {{name}}.

%% @doc Callbacks for the polish application.

-module({{appid}}_inets).

-export([start_link/0, stop/0, do/1, out/1]).

-include_lib("yaws/include/yaws.hrl").


start_link() ->
    start_link({{appid}}:http_server()).

start_link(yaws) ->
    SL = [{appmods,    [{"/", ?MODULE}]},
	  {port,       {{appid}}:port()},
	  {servername, {{appid}}:servername()},
	  {listen,     {{appid}}:ip()}],
    GL = [{logdir,     {{appid}}:log_dir()},
	  {cache_refresh_secs, 5}],
    ok = yaws:start_embedded({{appid}}:docroot(), SL, GL, "bfp"),
    {ok, whereis(yaws_sup)};

start_link(inets) ->
    inets:start(),
    {ok, Pid} =
        inets:start(httpd,
                    [{port,           {{appid}}:port()}
                     ,{server_name,   {{appid}}:servername()}
	             ,{bind_address,  {{appid}}:ip()}
                     ,{server_root,   "."}
                     ,{document_root, {{appid}}:docroot()}
                     ,{modules,       [?MODULE]}
                     ,{mime_types,    [{"css",  "text/css"},
                                       {"js",   "text/javascript"},
                                       {"html", "text/html"}]}
                    ]),
    link(Pid),
    {ok, Pid};

start_link(mochiweb) ->
    mochiweb:start(),
    Options = [{port,   {{appid}}:port()}
               ,{name,  {{appid}}:servername()}
               ,{ip,    {{appid}}:ip()}
               ,{loop,  fun(Req) -> do_mochiweb(Req) end}
              ],
    {ok, Pid} = mochiweb_http:start(Options),
    link(Pid),
    {ok, Pid}.


stop() ->
    httpd:stop_service({any, {{appid}}_deps:get_env(port, {{appid}}:default_port())}),
    ok.

do(Info) ->
    RequestBridge = simple_bridge:make_request(inets_request_bridge, Info),
    ResponseBridge = simple_bridge:make_response(inets_response_bridge, Info),
    {{appid}}:run(RequestBridge, ResponseBridge).

out(Info) ->
    RequestBridge = simple_bridge:make_request(yaws_request_bridge, Info),
    ResponseBridge = simple_bridge:make_response(yaws_response_bridge, Info),
    {{appid}}:run(RequestBridge, ResponseBridge).

do_mochiweb(Info) ->
    RequestBridge = simple_bridge:make_request(mochiweb_request_bridge, {Info,"./www"}),
    ResponseBridge = simple_bridge:make_response(mochiweb_response_bridge, {Info, "./www"}),
    {{appid}}:run(RequestBridge, ResponseBridge).

