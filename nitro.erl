%%% @author {{name}} <{{email}}>
%%% @copyright (C) YYYY, {{name}}

-module({{appid}}).

-export([rfc3339/0
         , rfc3339/1
         , gnow/0
         , gdate/0
         , gdate2datetime/1
	 , friendly_date/1
         , hostname/0
         , default_port/0
         , i2l/1
        ]).

-include_lib("nitrogen/include/wf.hrl").
           

default_port() -> 8080.

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


hostname() ->
    {ok,Host} = inet:gethostname(),
    Host.

i2l(I) when is_integer(I) -> integer_to_list(I);
i2l(L) when is_list(L)    -> L.
    

