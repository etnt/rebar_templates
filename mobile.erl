%%% @author {{name}} <{{email}}>
%%% @copyright (C) YYYY, {{name}}

-module({{appid}}).

-export([  run/2
         , rfc3339/0
         , rfc3339/1
         , gnow/0
         , gdate/0
         , gdate2datetime/1
	 , friendly_date/1
         , template/0
         , db_name/0
         , hostname/0
         , external_hostname/0
         , ip/0
         , port/0
         , servername/0
         , http_server/0
         , log_dir/0
         , docroot/0
         , top_dir/0
         , priv_dir/0
         , gettext_dir/0
         , couchdb_url/0
         , couchdb_host/0
         , couchdb_port/0
         , i2l/1
        ]).

-import({{appid}}_deps, [get_env/2]).

           
-define(is_bool(B), ((B =:= true) orelse (B =:= false))).

%% SimpleBridge entry
run(Request, Response) ->
    Response1 = Response:status_code(200),
    Response2 = Response1:header("Content-Type", "text/html"),
    Response3 = Response2:data(html()),
    Response3:build_response().

html() ->
    "<html><head></head><body>Hello World</body></html>".


couchdb_url() ->
    "http://"++couchdb_host()++":"++integer_to_list(couchdb_port()).

db_name()           -> get_env(db_name, "{{appid}}").
couchdb_host()      -> get_env(couchdb_host, "localhost").
couchdb_port()      -> get_env(couchdb_port, 5984).
log_dir()           -> get_env(log_dir, "./tmp").
docroot()           -> get_env(docroot, "./www").
servername()        -> get_env(servername, "localhost").
ip()                -> get_env(ip, {127,0,0,1}).
port()              -> get_env(port, 8283).
http_server()       -> get_env(http_server, inets).
external_hostname() -> get_env(external_hostname, hostname()).
template()          -> get_env(template, "./templates/grid.html").
gettext_dir()       -> priv_dir().
    

hostname() ->
    {ok,Host} = inet:gethostname(),
    Host.

top_dir() ->
    filename:join(["/"|lists:reverse(tl(lists:reverse(string:tokens(filename:dirname(code:which(?MODULE)),"/"))))]).

priv_dir() ->
    top_dir()++"/priv".

%%
%% @doc Return gregorian seconds as of now()
%%
gnow() ->
    calendar:datetime_to_gregorian_seconds(calendar:local_time()).

%%
%% @doc Return gregorian seconds as of today()
%%
gdate() -> calendar:datetime_to_gregorian_seconds({date(), {0,0,0}}).

%%
%% @doc Transform Gsecs to a {date(),time()} tuple.
%%
gdate2datetime(Secs) ->
    calendar:gregorian_seconds_to_datetime(Secs).

%%
%% @doc Time as a string in a standard format.
%%
rfc3339() ->
    rfc3339(calendar:now_to_local_time(now())).

rfc3339(Gsec) when is_integer(Gsec) ->
    rfc3339(gdate2datetime(Gsec));

rfc3339({ {Year, Month, Day}, {Hour, Min, Sec}}) ->
    io_lib:format("~4..0w-~2..0w-~2..0wT~2..0w:~2..0w:~2..0w~s",
                  [Year,Month,Day, Hour, Min, Sec, zone()]).  

friendly_date(Gsec) when is_integer(Gsec) ->
    friendly_date(gdate2datetime(Gsec));

friendly_date({ {Year, Month, Day}, {Hour, Min, Sec}}) ->
    io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w",
                  [Year,Month,Day, Hour, Min, Sec]).  

zone() ->
    Time = erlang:universaltime(),
    LocalTime = calendar:universal_time_to_local_time(Time),
    DiffSecs = calendar:datetime_to_gregorian_seconds(LocalTime) -
        calendar:datetime_to_gregorian_seconds(Time),
    zone(DiffSecs div 3600, (DiffSecs rem 3600) div 60).

zone(Hr, Min) when Hr < 0; Min < 0 ->
    io_lib:format("-~2..0w~2..0w", [abs(Hr), abs(Min)]);
zone(Hr, Min) when Hr >= 0, Min >= 0 ->
    io_lib:format("+~2..0w~2..0w", [Hr, Min]).


i2l(I) when is_integer(I) -> integer_to_list(I);
i2l(L) when is_list(L)    -> L.
    

