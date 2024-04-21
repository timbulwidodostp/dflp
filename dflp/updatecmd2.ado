*! version 1.0, 24-9-2021	
cap program drop updatecmd2
program define updatecmd2
version 14
	syntax anything, from(string) [froma(string) pkg(string)]  
	 confirm names `anything' 
    if `"`pkg'"'==""  local pkg `anything'
	confirm names `pkg'
    global p_k_g_ `pkg'
    global c_m_d_0 `anything' ${c_m_d_0}    
    global up_grade_`pkg' "tocheck" 
	cap mata: vfile = cat(`"`from'/`anything'.ado"') 
	if _rc{
		cap mata: vfile = cat(`"`froma'/`anything'.ado"')
		if _rc{ //failed to connnect the web, excute the cmd
			global up_grade_`pkg' `"failedto{`from'}"'
			$c_m_d_0
			cap macro drop p_k_g_
			cap macro drop c_m_d_0
			exit
		}
		local from `froma'		
	}
	global up_grade_`pkg' `"copyfrom{`from'}"'
	mata: vfile = select(vfile,vfile:!="")
	mata: vfile = usubinstr(vfile,char(9)," ",.)
	mata: vfile = select(vfile,!ustrregexm(vfile,"^( )+$"))
	mata: st_local("versiongit",vfile[1])
	local versiongit = ustrregexrf("`versiongit'","^[\D]+","")
	gettoken vers versiongit:versiongit, p(", ")
	local versiongit `vers'
	qui findfile `anything'.ado
	mata: vfile = cat("`r(fn)'")
	//mata: st_local("versionuse",subinstr(vfile[1]," ","",.))
	mata: vfile = select(vfile,vfile:!="")
	mata: vfile = usubinstr(vfile,char(9)," ",.)
	mata: vfile = select(vfile,!ustrregexm(vfile,"^( )+$"))
	mata: st_local("versionuse",vfile[1])
	local versionuse = ustrregexrf("`versionuse'","^[\D]+","")
	gettoken vers versionuse:versionuse, p(", ")
    local versionuse `vers'	

    compareversion `versiongit' `versionuse'
    local newv = r(l)
	if(`newv'){
		global f_r_o_m_ `from'
		db updateyorn
	}
	else{
		$c_m_d_0
		cap macro drop c_m_d_0
		cap macro drop p_k_g_
	}

end

cap program drop compareversion
program define compareversion, rclass

version 14

args x y

local xx = usubinstr(`"`x'"',".","",.)
local yy = usubinstr(`"`y'"',".","",.)

local nreal = ustrregexm(`"`xx'"',"\D")
if `nreal'{
   di as error `"`x' is not a valid version number"'
   di `"Note: The format of version number is #.#.#"'
   exit
}

local nreal = ustrregexm(`"`yy'"',"\D")
if `nreal'{
   di as error `"`y' is not a valid version number"'
   di `"Note: The format of version number is #.#.#"'
   exit
}

mata: _compareversion2()

return scalar l=r(l)
end

cap mata mata drop _compareversion()
cap mata mata drop _compareversion2()
cap mata mata drop _comparexy()

mata:
void function _compareversion()
{
    l=0
    vx=st_local("x")
    vy=st_local("y")
    vx=tokens(vx,".")
    vy=tokens(vy,".")
    vx=strtoreal(select(vx,vx:!="."))
    vy=strtoreal(select(vy,vy:!="."))
    vl =length(vx) -length(vy)
    if(vl>0) vy=vy,J(1,vl,0)
    else  vx=vx,J(1,vl,0)
    flag = vx - vy
    flag = select(flag,flag:!=0)
    if(length(flag)>0 & flag[1]>0){
       l=1
    }
 
    st_numscalar("r(l)",l)

	
}


void function _compareversion2()
{
    l=0
    vx=st_local("x")
    vy=st_local("y")
    if(vx==vy){
    	st_numscalar("r(l)",l)
    	exit()
    }
    vx=tokens(vx,".")
    vy=tokens(vy,".")
    vx=select(vx,vx:!=".")
    vy=select(vy,vy:!=".")

    minl=min((length(vx),length(vy)))
    
    if(vx[1..minl]==vy[1..minl]){
    	l = (length(vx)>length(vy))
    	st_numscalar("r(l)",l)
    	exit()    	
    }

    c=1
    while(c<=minl|l<1){
       l= _comparexy(vx[c],vy[c])
       c=c+1

    }

    
    st_numscalar("r(l)",l)

	
}

real scalar function _comparexy(string scalar a, string scalar b)
{
	la=strlen(a)
	lb=strlen(b)
	minl=min((la,lb))
	if(substr(a,1,minl)==substr(b,1,minl)){
	   flag = (la>lb)
	   return(flag)
	   exit()
	}
	c=1
	flag=0
    while(c<=minl & flag<1){
       x = strtoreal(substr(a,c,c))
       y = strtoreal(substr(b,c,c))
       flag=(x>y)
       c=c+1
    }
    return(flag)

}


end


