*! version 1.0	
cap program drop updatecmd
program define updatecmd
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
	cap di `vers'
	if _rc{
		di as red `"WARNING: Version number[`vers'] is not correctly identified."'
		di "The first line of ado should be organized as:"
		di "*! version #.# , datetime"
		di "----------------------------------------------------------------------"
		di _n
		$c_m_d_0
		cap macro drop p_k_g_
		cap macro drop c_m_d_0
		exit		
	}
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
	cap di `vers'
	if _rc{
		di as red `"WARNING: Version number[`vers'] is not correctly identified."'
		di "The first line of ado should be organized as:"
		di "*! version #.# , Datetime"
        di "--------------------------------------------------------------------"
        di _n
		$c_m_d_0
		cap macro drop p_k_g_
		cap macro drop c_m_d_0
		exit		
	}
    local versionuse `vers'	
	if(`versionuse'<`versiongit'){
		global f_r_o_m_ `from'
		db updateyorn
	}
	else{
		$c_m_d_0
		cap macro drop c_m_d_0
		cap macro drop p_k_g_
	}

end


