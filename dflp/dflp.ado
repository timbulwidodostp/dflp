*! version 1.3, 5Mar2022
cap program drop dflp
program define dflp, eclass
  version 16

    **********************************************
    *******Check whether a new version is available
    // global c_m_d_0 is used in the updatecmd.ado
    global c_m_d_0 `0'  
    local pkg dflp // updatecmd should be replaced with your package name

    //install the updatecmd package if it is missing
    cap which updatecmd
    if _rc{
      cap net install updatecmd, from("https://github.com/kerrydu/kgitee/raw/master/") replace
      if _rc{
         cap net install updatecmd, from("https://gitee.com/kerrydu/kgitee/raw/master/") replace
         if _rc global up_grade_`pkg' "updatecmd_is_missing"
       }
      
    }
	local updated 0
    //the first run of the command defines global up_grade_`pkg'
    if "${up_grade_`pkg'}"==""{ 
		local updated 1
        updatecmd dflp, from("https://gitee.com/kerrydu/dflp/raw/master/")  pkg(`pkg')      
    } 
	if `updated' exit
    ********************************************   
	*else{
	cap which getversion
	if _rc net install getversion, from("https://gitee.com/kerrydu/mepi/raw/master") replace		
	_get_version dflp
	_compile_mata, package(dflp) version(`package_version') verbose  
	qui mata mata mlib index
  
    gettoken xvars 0:0, parse("=")
    gettoken var 0:0, parse("=")
    gettoken yvars 0:0, parse(":")
    gettoken var 0:0, parse(":")
    syntax varlist [if] [in],[Time(varname) NORMalize EFFicient SAVing(string) Output Input Directional maxiter(numlist integer >0 max=1) tol(numlist max=1)]  
    local bvars `varlist'
	marksample touse
	
		if "`input'"!="" & "`output'"!=""{
			di as error `" ERROR: option {it:input} & {it:output} should not be specified simultaneously."'
			exit
		}

 		if "`input'"!="" & "`directional'"!=""{
			di as error `" ERROR: option {it:input} & {it:directional} should not be specified simultaneously."'
			exit
		}
		
 		if "`output'"!="" & "`directional'"!=""{
			di as error `" ERROR: option {it:output} & {it:directional} should not be specified simultaneously."'
			exit
		}
		
		if "`input'"!=""   local q i
		else if "`output'"!=""  local q o	
		else  local q d			
		`q'dflp `xvars' = `yvars' : `bvars' if `touse', sav(`saving') maxiter(`maxiter') tol(`tol') time(`time') `efficient' `normalize'
	*}



end


////subprograms

*! version 0.1  2021-8-31
* Kerry Du
cap program drop translog1
program def translog1,rclass
	version 10.1
	gettoken xvars 0: 0, p("=")
	gettoken eq 0: 0, p("=")
	gettoken yvars 0: 0, p(":")
	gettoken eq 0: 0, p(":")
	
  syntax varlist(min=1) [, t(varname) NORMalize Local(str)] 
     local bvars `varlist'  
     local nx: word count `xvars'	
	 local ny: word count `yvars'	
	 local nb: word count `bvars'	
	 
			if "`normalize'"=="" {
					foreach v of local xvars {
						qui gen ln`v'=ln(`v')
						label var ln`v' `"log(`v')"'
						qui gen ln`v'2 = 0.5*ln`v'^2
						label var ln`v'2 `"0.5 * ln`v'^2"'
						local xnews `xnews' ln`v' 
						local xnews2 `xnews2' ln`v'2 
					 }
					 
					foreach v of local yvars {
						qui gen ln`v'=ln(`v')
						label var ln`v' `"log(`v')"'
						qui gen ln`v'2 = 0.5*ln`v'^2
						label var ln`v'2 `"0.5 * ln`v'^2"'
						local ynews `ynews' ln`v' 
						local ynews2 `ynews2' ln`v'2 
					 }		
					foreach v of local bvars {
						qui gen ln`v'=ln(`v')
						label var ln`v' `"log(`v')"'
						qui gen ln`v'2 = 0.5*ln`v'^2
						label var ln`v'2 `"0.5 * ln`v'^2"'
						local bnews `bnews' ln`v' 
						local bnews2 `bnews2' ln`v'2 
					 }							 
					 		 					 
					
					local vlist `xvars' 
					local y `xvars' 
					foreach v of local vlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cxvars `cxvars' ln`v'_ln`v1'
					    }
					 }
					local vlist `yvars' 
					local y `yvars' 
					foreach v of local vlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cyvars `cyvars' ln`v'_ln`v1'
					    }
					 }					 
					local vlist `bvars' 
					local y `bvars' 
					foreach v of local vlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cbvars `cbvars' ln`v'_ln`v1'
					    }
					 }
					 
	
					foreach v of local xvars {
						foreach v1 of local yvars {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cxyvars `cxyvars' ln`v'_ln`v1'
					    }
					 }	
					 

					foreach v of local xvars {
						foreach v1 of local bvars {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cxbvars `cxbvars' ln`v'_ln`v1'
					    }
					 }					 
					foreach v of local yvars {
						foreach v1 of local bvars {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cybvars `cybvars' ln`v'_ln`v1'
					    }
					 }					 
					 
					 					
			 }
			else {
				    disp as green "Note: Variables are normalized by their means respectively before taking log."
					
					foreach v of local xvars {
					    qui su `v',meanonly
						local vmean=r(mean)						
						qui gen ln`v'=ln(`v'/`vmean')
						label var ln`v' `"log(`v')"'
						qui gen ln`v'2 = 0.5*ln`v'^2
						label var ln`v'2 `"0.5 * ln`v'^2"'
						local xnews `xnews' ln`v' 
						local xnews2 `xnews2' ln`v'2 
					 }
					 
					foreach v of local yvars {
					    qui su `v',meanonly
						local vmean=r(mean)						
						qui gen ln`v'=ln(`v'/`vmean')
						label var ln`v' `"log(`v')"'
						qui gen ln`v'2 = 0.5*ln`v'^2
						label var ln`v'2 `"0.5 * ln`v'^2"'
						local ynews `ynews' ln`v' 
						local ynews2 `ynews2' ln`v'2 
					 }		
					foreach v of local bvars {
					    qui su `v',meanonly
						local vmean=r(mean)						
						qui gen ln`v'=ln(`v'/`vmean')
						label var ln`v' `"log(`v')"'
						qui gen ln`v'2 = 0.5*ln`v'^2
						label var ln`v'2 `"0.5 * ln`v'^2"'
						local bnews `bnews' ln`v' 
						local bnews2 `bnews2' ln`v'2 
					 }						
					
					
					local vlist `xvars' 
					local y `xvars' 
					foreach v of local vlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cxvars `cxvars' ln`v'_ln`v1'
					    }
					 }
					local vlist `yvars' 
					local y `yvars' 
					foreach v of local vlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cyvars `cyvars' ln`v'_ln`v1'
					    }
					 }					 
					local vlist `bvars' 
					local y `bvars' 
					foreach v of local vlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cbvars `cbvars' ln`v'_ln`v1'
					    }
					 }
					 
	
					foreach v of local xvars {
						foreach v1 of local yvars {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cxyvars `cxyvars' ln`v'_ln`v1'
					    }
					 }	
					 

					foreach v of local xvars {
						foreach v1 of local bvars {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cxbvars `cxbvars' ln`v'_ln`v1'
					    }
					 }					 
					foreach v of local yvars {
						foreach v1 of local bvars {
							 qui gen ln`v'_ln`v1'=ln`v'*ln`v1'
							 label var ln`v'_ln`v1' `"ln`v' * ln`v1'"'
							 local cybvars `cybvars' ln`v'_ln`v1'
					    }
					 }					
					
				
					
			}
			
			if "`t'"!=""{
				qui egen t =group(`t')
				if "`normalize'"!="" {
					su t, meanonly
					qui replace t = t - r(mean)
				}
				qui gen double t2 = t^2
				label var t2 "t^2"
				local tvars t t2 
				foreach v of local xnews{
					qui gen double t`v' = t*`v'
					label var t`v' `"t*`v'"'
					local tvars `tvars' t`v'
				}

				foreach v of local ynews{
					qui gen double t`v' = t*`v'
					label var t`v' `"t*`v'"'
					local tvars `tvars' t`v'
				}

				foreach v of local bnews{
					qui gen double t`v' = t*`v'
					label var t`v' `"t*`v'"'
				    local tvars `tvars' t`v'
				}
			}
			

		
			if "`local'" != "" {
				c_local `local' `xnews' `ynews' `bnews'  `cxvars' `xnews2' `cyvars' `ynews2' `cbvars' `bnews2'  `cybvars' `cxyvars' `cxbvars' `tvars'
			 }
			 
			 genname `nx' `ny' `nb' `t'
			 local varsname `r(varsname)'
			 return local tvars `tvars'
			 return local xvars `xnews'
			 return local cxvars `cxvars'
			 return local xvars2 `xnews2'
			 return local yvars `ynews'
			 return local cyvars `cyvars'
			 return local yvars2 `ynews2'		
			 return local bvars `bnews'
			 return local cbvars `cbvars'
			 return local bvars2 `bnews2'	
			 return local cxyvars `cxyvars'
			 return local cxbvars `cxbvars'
			 return local cybvars `cybvars'			 
			 return local varsname `varsname'
					
	end
	
	
	
	cap program drop genname
	program define genname, rclass
	version 11
	args nx ny nb t
	
	forv j=1/`nx'{
		local varsname `varsname' x.`j'. //xj
	}

	forv j=1/`ny'{
		local varsname `varsname' y.`j'.  //yj
	}


	forv j=1/`nb'{
		local varsname `varsname' b.`j'.  //bj
	}

	*local nx 5
	forv j=1/`=`nx'-1'{
		forv i=`=`j'+1'/`nx'{
		local varsname `varsname' x`j'_x`i'_  //xjxi
	}
	}


	forv j=1/`nx'{
		local varsname `varsname' x*`j'* //x^2
	}


	forv j=1/`=`ny'-1'{
		forv i=`=`j'+1'/`ny'{
		local varsname `varsname' y`j'_y`i'_ //yjyi
	}
	}


	forv j=1/`ny'{
		local varsname `varsname' y*`j'* // y^2
	}


	forv j=1/`=`nb'-1'{
		forv i=`=`j'+1'/`nb'{
		local varsname `varsname' b_`j'b`i'_ //bjbi
	}
	}


	forv j=1/`nb'{
		local varsname `varsname' b*`j'* // b^2
	}


	forv j=1/`ny'{
		forv i=1/`nb'{
		local varsname `varsname' y`j'b`i'yb //yjbi
	}
	}


	forv j=1/`nx'{
		forv i=1/`ny'{
		local varsname `varsname' x`j'y`i'xy //xjyi
	}
	}

	forv j=1/`nx'{
		forv i=1/`nb'{
		local varsname `varsname' x`j'b`i'xb //xjbi
	}
	}	

	if `"`t'"'!=""{
		local varsname `varsname' t. t*   
		forv j=1/`nx'{
			local varsname `varsname' x`j'tx
		}
		forv j=1/`ny'{
			local varsname `varsname' y`j'ty
		}
		forv j=1/`nb'{
			local varsname `varsname' b`j'tb
		}		
	}

	
	return local varsname `varsname'
	
end

//////////////////////////////////////////


cap program drop tranquad
program def tranquad,rclass
	version 10.1
	gettoken xvars 0: 0, p("=")
	gettoken eq 0: 0, p("=")
	gettoken yvars 0: 0, p(":")
	gettoken eq 0: 0, p(":")
	
  syntax varlist(min=1) [, t(varname) NORMalize Local(str)] 
     local bvars `varlist'  
     local nx: word count `xvars'	
	 local ny: word count `yvars'	
	 local nb: word count `bvars'	
	 
	 if "`normalize'"!=""{
	 	foreach v in `xvars' `yvars' `bvars' `t' {
			su `v', meanonly
			qui replace `v' = `v'/r(mean)
			label var `v' `"normalized `v'"'
		}
		
	 }
	 
	 

					foreach v of local xvars {
						qui gen `v'2 = 0.5*`v'^2
						label var `v'2 "0.5*`v'^2"
						local xnews2 `xnews2' `v'2 
					 }
					 
					foreach v of local yvars {
						qui gen `v'2 = 0.5*`v'^2
						label var `v'2 "0.5 * `v'^2"
						local ynews2 `ynews2' `v'2 
					 }		
					foreach v of local bvars {
						qui gen `v'2 = 0.5*`v'^2
						label var `v'2 "0.5 * `v'^2"
						local bnews2 `bnews2' `v'2 
					 }							 
					 		 					 
					
					local vlist `xvars' 
					local y `xvars' 
					foreach v of local vlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen `v'_`v1'=`v'*`v1'
							 label var `v'_`v1' "`v' * `v1'"
							 local cxvars `cxvars' `v'_`v1'
					    }
					 }
					local vlist `yvars' 
					local y `yvars' 
					foreach v of local vlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen `v'_`v1'=`v'*`v1'
							 label var `v'_`v1' "`v' * `v1'"
							 local cyvars `cyvars' `v'_`v1'
					    }
					 }					 
					local vlist `bvars' 
					local y `bvars' 
					foreach v of local vlist {
						gettoken x y: y
						foreach v1 of local y {
							 qui gen `v'_`v1'=`v'*`v1'
							 label var `v'_`v1' "`v' * `v1'"
							 local cbvars `cbvars' `v'_`v1'
					    }
					 }
					 
	
					foreach v of local xvars {
						foreach v1 of local yvars {
							 qui gen `v'_`v1'=`v'*`v1'
							 label var `v'_`v1' "`v' * `v1'"
							 local cxyvars `cxyvars' `v'_`v1'
					    }
					 }	
					 

					foreach v of local xvars {
						foreach v1 of local bvars {
							 qui gen `v'_`v1'=`v'*`v1'
							 label var `v'_`v1' "`v' * `v1'"
							 local cxbvars `cxbvars' `v'_`v1'
					    }
					 }					 
					foreach v of local yvars {
						foreach v1 of local bvars {
							 qui gen `v'_`v1'=`v'*`v1'
							 label var `v'_`v1' "`v' * `v1'"
							 local cybvars `cybvars' `v'_`v1'
					    }
					 }
					 
					 
			if "`t'"!=""{
				qui egen t =group(`t')
				qui gen double t2 = t^2
				label var t2 "t^2"
				local tvars t t2 
				foreach v of local xvars{
					qui gen double t`v' = t*`v'
					label var t`v' "t * `v'"
					local tvars `tvars' t`v'
				}

				foreach v of local yvars{
					qui gen double t`v' = t*`v'
					label var t`v' "t * `v'"
					local tvars `tvars' t`v'
				}

				foreach v of local bvars{
					qui gen double t`v' = t*`v'
					label var t`v' "t * `v'"
				    local tvars `tvars' t`v'
				}
			}					 
					 
					 		
			if "`local'" != "" {
				c_local `local' `xvars' `yvars' `bvars'  `cxvars' `xnews2' `cyvars' `ynews2' `cbvars' `bnews2'  `cybvars' `cxyvars' `cxbvars' `tvars'
			 }
			 
			 genname `nx' `ny' `nb' `t'
			 local varsname `r(varsname)'
			 
			 return local xvars `xvars'
			 return local cxvars `cxvars'
			 return local xvars2 `xnews2'
			 return local yvars `yvars'
			 return local cyvars `cyvars'
			 return local yvars2 `ynews2'		
			 return local bvars `bvars'
			 return local cbvars `cbvars'
			 return local bvars2 `bnews2'	
			 return local cxyvars `cxyvars'
			 return local cxbvars `cxbvars'
			 return local cybvars `cybvars'	
			 return local tvars   `tvars'	
			 return local varsname `varsname'
					
	end
	
//////////////////////////////////////
capture program drop ddflp
program define ddflp, eclass
    version 16
       gettoken xvars 0:0, parse("=")
       gettoken var 0:0, parse("=")
       gettoken yvars 0:0, parse(":")
       gettoken var 0:0, parse(":")
       syntax varlist [if] [in],[Time(varname) EFFicient NORMalize SAVing(string) maxiter(numlist integer >0 max=1) tol(numlist max=1)]   
       local bvars `varlist'
        marksample touse 
		markout `touse' `xvars' `yvars' `bvars'
		preserve
        qui keep `touse' `xvars' `yvars' `bvars' `time'
		qui keep if `touse'
		local nx: word count `xvars'	
		local ny: word count `yvars'	
		local nb: word count `bvars'

		if "`time'"!=""{
			tempvar time2
			qui egen `time2' = group(`time')
		}


		tranquad `xvars' = `yvars' : `bvars', local(allvars) t(`time2') `normalize'
		local varsname `r(varsname)'
		if "`maxiter'"==""{
			local maxiter=-1
		}
		if "`tol'"==""{
			local tol=-1
		} 		
		qui gen double Dv = .
		label var Dv "Directional distance function"		
		mata: ddf_lp("`allvars'","`touse'",`nx',`ny',`nb',`maxiter',`tol')
		tempname beta
		matrix `beta' = r(beta)
		//mat list `beta'
		matrix colnames `beta' = _Cons  `allvars'
        if(`"`saving'"'!=""){
			cap drop `touse'
			qui gen _Row = _n
			label var _Row "Row # in the original data set"
			order _Row `xvars' `yvars' `bvars' `allvars' Dv
   
        if "`efficient'"!=""{
            foreach v in `bvars'{
                qui replace `v' = `v' -Dv
            }
            foreach v in `yvars'{
                qui replace `v' =`v' +Dv
            }
        }
        local xybvars `xvars' `yvars' `bvars'
        local dropgen: list allvars - xybvars
        cap drop `dropgen'
        tranquad `xvars' = `yvars' : `bvars', local(allvars) t(`time2') //原始数据已经除均值
        foreach v in  `xvars' `yvars' `bvars'{
            qui gen _D`v' =0
            label var _D`v' "Partial derivative of Dv to `v'"
            foreach j in `allvars'{
                if "`j'"=="`v'_`v'"{
                    qui replace _D`v' =_D`v'+ `beta'[1,"`j'"]*`v'
                }
                else if strpos("`j'","`v'"){
                    qui replace _D`v'=_D`v'+ `beta'[1,"`j'"]*`j'/`v'
                }
            }
        }
			save `saving'
		} 

		matrix `beta' = `beta''
		matrix rownames `beta' = _Cons  `allvars'
		matrix colnames `beta' =  Coefficient
        local r = rowsof(`beta')-1
		local rf "--"
		forvalues i=1/`r' {
			local rf "`rf'&"
		}		
		local rf "`rf'-"
		local cf "| %10s|%12.4f |"	
		dis _n in gr "Parameters in Directional Distance function:"
		matlist `beta',  cspec(`cf') rspec(`rf') noblank rowtitle("Variable")	
		ereturn matrix parameters = `beta'
     
		restore

end
//////////////////////////////////////////////////

capture program drop idflp
program define idflp, eclass
    version 16
       gettoken xvars 0:0, parse("=")
       gettoken var 0:0, parse("=")
       gettoken yvars 0:0, parse(":")
       gettoken var 0:0, parse(":")
       syntax varlist [if] [in],[Time(varname) NORMalize EFFicient SAVing(string) ///
	                         maxiter(numlist integer >0 max=1) tol(numlist max=1)]   
       local bvars `varlist'
        marksample touse 
		markout `touse' `xvars' `yvars' `bvars'
		preserve
        qui keep `touse' `xvars' `yvars' `bvars'  `time'	
		if "`maxiter'"==""{
			local maxiter=-1
		}
		if "`tol'"==""{
			local tol=-1
		} 
		local nx: word count `xvars'	
		local ny: word count `yvars'	
		local nb: word count `bvars'
		qui keep if `touse'

		qui if "`time'"!="" {
			tempvar `time2' 
			qui egen `time2' =group(`time')
		}
		if "`normalize'"!=""{
			foreach v in `xvar' `yvars' `bvars'{
				su `v', meanonly
				qui replace `v' = `v'/r(mean)
				label var `v' `"`normalized `v''"'
			} 
			qui su `time2', meanonly
			qui replace `time2' =`time2' -r(mean)
			label var `time2' `"`normalized `time''"'
		}
		

		
		translog1 `xvars' = `yvars' : `bvars', local(allvars) t(`time2') 
		local varsname `r(varsname)'
		
		qui gen double Dv = .
		label var Dv "Input distance function"		
		mata: temp = idf_lp("`allvars'","`touse'",`nx',`ny',`nb',`maxiter',`tol')
		tempname beta
		matrix `beta' = r(beta)
		//mat list `beta'
		matrix colnames `beta' = _Cons  `allvars'

       if(`"`saving'"'!=""){
			cap drop `touse'
			qui gen _Row = _n
			label var _Row "Row # in the original data set"
			order _Row `xvars' `yvars' `bvars' `allvars' Dv
   
        if "`efficient'"!=""{
            foreach v in `bvars'{
                qui replace `v' = `v'/Dv
            }
            foreach v in `xvars'{
                qui replace `v' =`v'/Dv
            }
        }
 
        cap drop `allvars'
        translog1 `xvars' = `yvars' : `bvars', local(allvars) t(`time2') 
        foreach v in  `xvars' `yvars' `bvars'{
            qui gen lnD`v' =0
            label var lnD`v' "Partial derivative of lnDv to `v'"
            foreach j in `allvars'{
                if "`j'"=="`v'_`v'"{
                    qui replace lnD`v' =lnD`v'+ `beta'[1,"`j'"]*`v'
                }
                else if strpos("`j'","`v'"){
                    qui replace lnD`v'=lnD`v'+ `beta'[1,"`j'"]*`j'/`v'
                }
            }
        }
			save `saving'
		} 		
		
		
		
		matrix `beta' = `beta''
		matrix rownames `beta' = _Cons  `allvars'
		matrix colnames `beta' =  Coefficient
        local r = rowsof(`beta')-1
		local rf "--"
		forvalues i=1/`r' {
			local rf "`rf'&"
		}		
		local rf "`rf'-"
		local cf "| %10s|%12.4f |"	
		dis _n in gr "Parameters in Input Distance function:"
		matlist `beta',  cspec(`cf') rspec(`rf') noblank rowtitle("Variable")	
		ereturn matrix parameters = `beta'
		restore

end

/////////////////////////////////////////

capture program drop odflp
program define odflp, eclass
    version 16
       gettoken xvars 0:0, parse("=")
       gettoken var 0:0, parse("=")
       gettoken yvars 0:0, parse(":")
       gettoken var 0:0, parse(":")
       syntax varlist [if] [in],[Time(varname) NORMalize EFFicient SAVing(string) ///
	                 maxiter(numlist integer >0 max=1) tol(numlist max=1)]   
       local bvars `varlist'
        marksample touse 
		markout `touse' `xvars' `yvars' `bvars'
        local cvars : list xvars & yvars
		if `"`cvars'"'!=""{
			di as error `" ERROR: `cvars' should not be specified as inputvars and  desirable_outputvars simultaneously."'
			exit
		}

        local cvars : list xvars & bvars
		if `"`cvars'"'!=""{
			di as error `" ERROR: `cvars' should not be specified as inputvars and  undesirable_outputvars simultaneously."'
			exit
		}		

        local cvars : list yvars & bvars
		if `"`cvars'"'!=""{
			di as error `" ERROR: `cvars' should not be specified as desirable_outputvars and  undesirable_outputvars simultaneously."'
			exit
		}			

		preserve
        qui keep `touse' `xvars' `yvars' `bvars'  `time'	
		if "`maxiter'"==""{
			local maxiter=-1
		}
		if "`tol'"==""{
			local tol=-1
		} 
		local nx: word count `xvars'	
		local ny: word count `yvars'	
		local nb: word count `bvars'
		qui keep if `touse'

		qui if "`time'"!="" {
			tempvar `time2' 
			qui egen `time2' =group(`time')
		}

		
		if "`normalize'"!=""{
			foreach v in `xvar' `yvars' `bvars'{
				su `v', meanonly
				qui replace `v' = `v'/r(mean)
				label var `v' `"`normalized `v''"'

			} 
			qui su `time2', meanonly
			qui replace `time2' =`time2' -r(mean)
			label var `time2' `"`normalized `time''"'

		}		
		
		
		translog1 `xvars' = `yvars' : `bvars', local(allvars) t(`time2') 
		local varsname `r(varsname)'
		
		qui gen double Dv = .
		label var Dv "Output distance function"		
		mata: odf_lp("`allvars'","`touse'",`nx',`ny',`nb',`maxiter',`tol')
		tempname beta
		matrix `beta' = r(beta)
		//mat list `beta'
		matrix colnames `beta' = _Cons  `allvars'

       if(`"`saving'"'!=""){
			cap drop `touse'
			qui gen _Row = _n
			label var _Row "Row # in the original data set"
			order _Row `xvars' `yvars' `bvars' `allvars' Dv
   
        if "`efficient'"!=""{
            foreach v in `bvars'{
                qui replace `v' = `v'/Dv
            }
            foreach v in `yvars'{
                qui replace `v' =`v'/Dv
            }
        }
 
        cap drop `allvars'
        translog1 `xvars' = `yvars' : `bvars', local(allvars) t(`time2') 
        foreach v in  `xvars' `yvars' `bvars'{
            qui gen lnD`v' =0
            label var lnD`v' "Partial derivative of lnDv to `v'"
            foreach j in `allvars'{
                if "`j'"=="`v'_`v'"{
                    qui replace lnD`v' =lnD`v'+ `beta'[1,"`j'"]*`v'
                }
                else if strpos("`j'","`v'"){
                    qui replace lnD`v'=lnD`v'+ `beta'[1,"`j'"]*`j'/`v'
                }
            }
        }
			save `saving'
		} 		
		

		matrix `beta' = `beta''
		matrix rownames `beta' = _Cons  `allvars'
		matrix colnames `beta' =  Coefficient
        local r = rowsof(`beta')-1
		local rf "--"
		forvalues i=1/`r' {
			local rf "`rf'&"
		}		
		local rf "`rf'-"
		local cf "| %10s|%12.4f |"	
		dis _n in gr "Parameters in Output Distance function:"	
		matlist `beta',  cspec(`cf') rspec(`rf') noblank rowtitle("Variable")	
		ereturn matrix parameters = `beta'

        
		restore

end

