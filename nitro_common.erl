%% @author {{name}} <{{email}}>
%% @copyright {{year}} {{name}}

-module({{appid}}_common).

-include_lib ("nitrogen/include/wf.hrl").

-export([title/0
         , header/1
         , footer/0
         , right/0
         , left/0
        ]).

title() ->
    "{{appid}}".


right() ->
    #panel { class=menu, body=["RIGHT"] }.


left() ->
    #panel { class=menu, body=["LEFT"] }.


header(Selected) ->
    wf:wire(Selected, #add_class { class=selected }),
    #panel { class=menu, body=[
        #link { id=home,   url='/',            text="Home"  },
        #link { id=logout, url='/logout',      text="Logout"  },
        #link { id=about,  url='/about',       text="About"  }
    ]}.


footer() ->
    [#br{},
     #panel { class=credits, body=[
        "
        Copyright &copy; {{year}} <a href='{{www}}'>{{name}}</a>. 
        Released under the MIT License.
        "
    ]}].

