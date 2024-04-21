{smcl}
{* *! version 0.4  29 Oct 2019}{...}
{cmd:help dflp}
{hline}

{title:Title}

{phang}
{bf:dflp} {hline 2} Estimating Input/Output/Directional Distance Function using linear programming techniques

{title:Syntax}

{p 8 21 2}
{cmd:dflp} {it:{help varlist:inputvars}} {cmd:=} {it:{help varlist:desirable_outputvars}} {cmd::} {it:{help varlist:undesirable_outputvars}} 
 {ifin}  [,{it:options}]


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt sav:ing(filename[,replace])}}specifies that the results be saved in {it:filename}.dta. 
{p_end}


{synopt:{cmdab:in:put}}specifies estimating Input Distance Function.
{p_end}

{synopt:{cmdab:out:put}}specifies estimating Output Distance Function.
{p_end}


{synopt:{cmdab:dir:ectional}}specifies estimating Directional Distance Function. By default, DDF is assumed. 
{p_end}


{synopt:{cmdab:t:ime:(varname)}}specifies the time period variable. 
{p_end}


{synopt:{cmdab:norm:alize}} normalizes the variables. 
{p_end}


{synopt:{cmdab:eff:icient}} computes the partial derivatives on the fronteir. 
{p_end}


{synopt:{opt maxiter(#)}}specifies the maximum number of iterations, which must be an integer greater than 0. The default value of maxiter is 16000.
{p_end}

{synopt:{opt tol(real)}}specifies the convergence-criterion tolerance, which must be greater than 0.  The default value of tol is 1e-8.
{p_end}

{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:dflp} selects the input and output variables in the opened data set and estimates teh distance function by options specified. 

{phang}
The dflp program uses the buit-in mata function linearprogram(). Stata 16 or later is required.

{phang}
Variable names must be identified by inputvars for input variable, by desirable_outputvars for desirable output variable,  and by undesirable_outputvars for undesirable output variable
 to allow that {cmd:dflp} program can identify and handle the multiple input-output data set.



{title:Examples}

{phang}{"use ...\example_lp.dta"}

{phang}{cmd:. dflp labor capital energy=gdp:co2, in sav(lp_result)}

{phang}{cmd:. dflp labor capital energy=gdp:co2, out sav(lp_result)}

{phang}{cmd:. dflp labor capital energy=gdp:co2, dir sav(lp_result, replace)}



{title:Saved Results}

{psee}
Matrix:

{psee}
{cmd: r(parameters)} the stored coefficients of the distance function.
{p_end}


{marker references}{...}
{title:References}

{phang}
Färe, R., Grosskopf, S., Lovell, C.A.K., Yaisawarng, S., 1993. Derivation of Shadow Prices for Undesirable Outputs: A Distance Function Approach. The Review of Economics and Statistics, 75(2):374-380.

{phang}
Hailu, A., Veeman, T.S., 2000. Environmentally Sensitive Productivity Analysis of the Canadian Pulp and Paper Industry, 1959-1994: An Input Distance Function Approach. Journal of Environmental Economics and Management, 40: 251-274.

{phang}
Färe, R., Grosskopf, S., Noh, D., Weber, W., 2005. Characteristics of A Polluting Technology: Theory and Practice. Journal of Econometrics, 126: 469-492.




{title:Author}

{psee}
Kerry Du

{psee}
Xiamen University

{psee}
Xiamen, China

{psee}
E-mail: kerrydu@xmu.edu.cn
{p_end}


{psee}
Yu Zhao

{psee}
Shandong University

{psee}
Weihai, China

{psee}
E-mail: zhaoyu_yep@163.com
{p_end}


{psee}
Ning Zhang

{psee}
Shandong University

{psee}
Weihai, China

{psee}
E-mail: zn928@naver.com
{p_end}
