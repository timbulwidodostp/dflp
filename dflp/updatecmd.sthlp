{smcl}
{right:version 1.0}
{title:Title}

{phang}
{cmd:updatecmd} {hline 2} Check the update version of Stata packages 


{title:Syntax}

{p 8 16 2}
{cmd: updatecmd}  {it:commandname}  {cmd:,} {it:from(website)} [options]
{p_end}


{title:Options}

{p 4 4 2}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt from(website)}}specifies the website for installing the new version of the package. {p_end}

{synopt:{opt froma(website)}}specifies the second source for installing the new version of the package. {p_end}

{synopt:{opt pkg(packagename)}}specifies the packagename including the {it:commandname}. By default, pkg({it:commandname}) ia assumed. {p_end}

{synoptline}
{p2colreset}{...}



{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:updatecmd} can be nested in a user-written command for checking whether a new version is available.  A demo is structured as follows:

{phang}

*! version 0.02 
cap program drop demo_updatecmd
program define demo_updatecmd
    version 16

    **********************************************
    *******Check whether a new version is available
    // global c_m_d_0 is used in the updatecmd.ado
    global c_m_d_0 `0'  
    local pkg updatecmd // updatecmd should be replaced with your package name

    //install the updatecmd package if it is missing
    cap which updatecmd
    if _rc{
      cap net install updatecmd, from("https://github.com/kerrydu/kgitee/raw/master/") replace
      if _rc{
         cap net install updatecmd, from("https://gitee.com/kerrydu/kgitee/raw/master/") replace
         if _rc global up_grade_`pkg' "updatecmd_is_missing"
       }
      
    }

    //the first run of the command defines global up_grade_`pkg'
    local checkcmd 0
    if "${up_grade_`pkg'}"==""{ 
        local checkcmd 1
        updatecmd demo_updatecmd, from("https://gitee.com/kerrydu/kgitee/raw/master/")   ///
                                  froma("https://github.com/kerrydu/kgitee/raw/master/") ///
                                  pkg(`pkg') 	
    } 
    if `checkcmd' exit
    ********************************************


    di "hello, your code written here" // the content of your command placed here
   

end

{phang}
note: version number should be writen in REAL number. e.g., 1.2334 can be identied 
while those like 1.2.345 and 1.234a would not. 



{title:Author}

{p 4 4 2}
Kerry Du     {break}
Xiamen University      {break}
Email:kerrydu@xmu.edu.cn     {break}
