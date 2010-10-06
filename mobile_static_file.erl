%    -*- Erlang -*- 
%    File:	rest_appmod.erl
%    Author:	Nadia Mohedano Troyano
%
%  Adapted to SimpleBridge by etnt@redhoterlang.com
%

-module({{appid}}_static_file).

-export([dispatch/1]).

-include("{{appid}}.hrl").
-include_lib("yaws/include/yaws_api.hrl").

dispatch(#controller{response = Response, cpath = CPath, path = Path})  -> 
    File = filename:join([{{appid}}:top_dir(),"www",CPath]++Path),
    {ok, Bin} = file:read_file(File),

    %% Calculate expire date far into future...
    Seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
    TenYears = 10 * 365 * 24 * 60 * 60,
    Seconds1 = calendar:gregorian_seconds_to_datetime(Seconds + TenYears),
    ExpireDate = httpd_util:rfc1123_date(Seconds1),

    {{appid}}:mk_response(Response, 200,
                       [{"Content-Type", figure_out_content_type(File)},
                        {"Expires", ExpireDate}],
                       Bin).


figure_out_content_type(Name) ->
    case lists:reverse(string:tokens(Name, ".")) of
        [X|_] -> what_content_type(X);
        _     -> what_content_type(undefined)
    end.

what_content_type(Suffix) -> 
    try 
        {_Type, ContentType} = mime_types:t(Suffix),
        ContentType
    catch
        _:_ ->
            "application/octet-stream"
    end.
