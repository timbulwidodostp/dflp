version 16
// Versioning
_get_version dflp
assert("`package_version'" != "")
mata: string scalar dflp_version() return("`package_version'")
mata: string scalar dflp_stata_version() return("`c(stata_version)'")
mata: string scalar dflp_joint_version() return("`package_version'|`c(stata_version)'")

///////
cap mata mata drop idf_lp()
cap mata mata drop odf_lp()
cap mata mata drop ddf_lp()

//////////////
mata: 

void function  idf_lp(string scalar varsdata,
                      string scalar touse,
					  real   scalar nx, 
					  real   scalar ny,
					  real   scalar nb,
					  real   scalar maxiter,
					  real   scalar tol)
{
		data = st_data(.,varsdata,touse)
		names= "_Cons", tokens(st_local("varsname")) // 变量对应名称
		nid = 1..length(names)

		N=rows(data)
        data = J(N,1,1),data

		c=colsum(data) //目标函数

		// 第一个约束： -lnD<=0
		A1 = data
		b1 = J(N,1,0)
		A1 = -A1 // 方向需要变化

		//第二个约束：\sum(beta_x) =1
		A2 = J(1,length(c),0)
		selectid = select(nid,strpos(names,"x.")) // 关于lnx的提取赋值为1
		A2[selectid]=J(1,length(selectid),1)
		b2=1

		//第三个约束： \sum(beta_xx')=0 x'=1...nx 

		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,"x1_x")) // x1*x1+x1*x2+x1*x3=0
		AA[selectid]=J(1,length(selectid),1) 
		selectid = select(nid,strpos(names,"x*1*"))
		AA[selectid]=J(1,length(selectid),1) 
		A4 = AA
		b4 = 0	
		

		
		for(j=2;j<=nx;j++){		
		   AA = J(1,length(c),0)
		   selectid = select(nid,strpos(names,sprintf("x%f_x",j))) // xn*x1+xn*x2+xn*x3=0
		   AA[selectid]=J(1,length(selectid),1)
		   selectid = select(nid,strpos(names,sprintf("x*%f*",j)))
		   AA[selectid]=J(1,length(selectid),1) 
		   A4 = A4 \ AA
		   b4 = b4 \ 0 
		}
		
		//第四个约束： sum(\delta_xy)=0 y=1...ny
		
		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,"y1xy"))  // x1yn+x2yn+...=0
		AA[selectid]=J(1,length(selectid),1) // x`i'y1xy
		A4 = A4 \ AA	
		b4 = b4 \ 0
		
	
		for(j=2;j<=ny;j++){
			AA = J(1,length(c),0)
			selectid = select(nid,strpos(names,sprintf("y%fxy",j)))  // x1yn+x2yn+...=0
			AA[selectid]=J(1,length(selectid),1) // x`i'y`j'xy
			A4 = A4 \ AA
			b4 = b4 \ 0
		}
		
	
		//第四个约束： sum(\delta_xb)=0 b=1...nb
		for(i=1; i<=nb; i++){ // nx改为nb
			AA = J(1,length(c),0)
			selectid = select(nid,strpos(names,sprintf("b%fxb",i))) //  延续y的设定
			AA[selectid]=J(1,length(selectid),1) // x`i'b1xb
			A4 = A4 \ AA
			b4 = b4 \ 0	
			}
		//时间tx的约束：sum(\eta_tx)=0
		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,"tx")) 
		if(length(selectid)>0){
			AA[selectid]=J(1,length(selectid),1)
			A4 = A4 \ AA
			b4 = b4 \ 0
		}		
		

		//第5个约束：partial lnD / partial lnY <=0 
		//不同与ODF，为了满足Stata线性规划的标准形式，不需要进行变号其余不变
		A5 = J(N,length(c),0)
		selectid = select(nid,strpos(names,"y.1."))
		A5[.,selectid]=J(N,1,1)
		lny = data[.,selectid]
		data2=data
		data2[.,select(1..length(names),strpos(names,"y*"))]=data2[.,select(1..length(names),strpos(names,"y*"))]*2
		//selectid = select(nid,strpos(names,"y1_")),select(nid,strpos(names,"y*1*"))
		//selectid =selectid, select(nid,strpos(names,"y1x")),select(nid,strpos(names,"y1b"))
		selectid = select(nid,ustrregexm(names,"y1[^0-9]")),select(nid,strpos(names,"y*1*"))
		A5[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lny)
		b5 = J(N,1,0)
		//A5 = -A5
		
		for(j=2;j<=ny;j++){
			AA = J(N,length(c),0)
			selectid = select(nid,strpos(names,sprintf("y.%f.",j)))
			AA[.,selectid]=J(N,1,1)
			lny = data[.,selectid]
			//selectid = select(nid,strpos(names,sprintf("y%f_",j))),select(nid,strpos(names,sprintf("y*%f*",j)))
			//selectid =selectid, select(nid,strpos(names,sprintf("y%fx",j))),select(nid,strpos(names,sprintf("y%fb",j)))
			selectid = select(nid,ustrregexm(names,sprintf("y%f[^0-9]",j))),select(nid,strpos(names,sprintf("y*%f*",j)))
			AA[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lny)	
			//A5  = A5 \ -AA
			A5  = A5 \ AA
			b5 = b5 \ J(N,1,0)
		}

		//A5 = -A5 这个条件不需要了

		//第6个约束：- partial lnD / partial lnB <=0
		//不同与ODF，为了满足Stata线性规划的标准形式，需要进行变号，其余不变
		
		
		A6 = J(N,length(c),0)
		selectid = select(nid,strpos(names,"b.1."))
		A6[.,selectid]=J(N,1,1)
		lnb = data[.,selectid]
		data2=data
		data2[.,select(1..length(names),strpos(names,"b*"))]=data2[.,select(1..length(names),strpos(names,"b*"))]*2
		//selectid = select(nid,strpos(names,"b1_")),select(nid,strpos(names,"b*1*"))
		//selectid =selectid, select(nid,strpos(names,"b1x")),select(nid,strpos(names,"b1y"))
		selectid = select(nid,ustrregexm(names,"b1[^0-9]")),select(nid,strpos(names,"b*1*"))
		A6[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lnb)
		b6 = J(N,1,0)

		for(j=2;j<=nb;j++){
			AA = J(N,length(c),0)
			selectid = select(nid,strpos(names,sprintf("b.%f.",j)))
			AA[.,selectid]=J(N,1,1)
			lnb = data[.,selectid]
			//selectid = select(nid,strpos(names,sprintf("b%f_",j))),select(nid,strpos(names,sprintf("b*%f*",j)))
			//selectid =selectid,select(nid,strpos(names,sprintf("b%fx",j))),select(nid,strpos(names,sprintf("b%fy",j)))
			selectid = select(nid,ustrregexm(names,sprintf("b%f[^0-9]",j))),select(nid,strpos(names,sprintf("b*%f*",j)))
			AA[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lnb)	
			A6  = A6 \ AA	
			b6 = b6 \ J(N,1,0)
		}
        A6 = -A6
		
		//第7个约束：- partial lnD / partial lnX <=0
		//IDF需要加入关于lnD与lnx求偏导的约束条件
		
		// x可能有很多，先以X1为基准进行约束，然后再循环，好像也可以整合在一块
		A7 = J(N,length(c),0)
		selectid = select(nid, strpos(names, "x.1.")) 
		A7[.,selectid] = J(N,1,1)
		lnx = data[.,selectid]
		data2 = data
		data2[.,select(1..length(names),strpos(names,"x*"))]=data2[.,select(1..length(names),strpos(names,"x*"))]*2 //关于X^2求导需乘以2
		//selectid = select(nid,strpos(names,"x1_")),select(nid,strpos(names,"x*1*"))
		//selectid =selectid, select(nid,strpos(names,"x1y")),select(nid,strpos(names,"x1b"))
		selectid = select(nid,ustrregexm(names,"x1[^0-9]")),select(nid,strpos(names,"x*1*"))		
		A7[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lnx) 
		// 相当于把求导失去的lnx除掉了
		b7 = J(N,1,0)
		
		for(j=2;j<=nx;j++){
			AA = J(N,length(c),0)
			selectid = select(nid, strpos(names, sprintf("x.%f.",j)))
			AA[.,selectid]=J(N,1,1)
			lnx = data[.,selectid]
			//selectid = select(nid,strpos(names,sprintf("x%f_",j))),select(nid,strpos(names,sprintf("x*%f*",j)))
			//selectid =selectid,select(nid,strpos(names,sprintf("x%fy",j))),select(nid,strpos(names,sprintf("x%fb",j)))
			selectid = select(nid,ustrregexm(names,sprintf("x%f[^0-9]",j))),select(nid,strpos(names,sprintf("x*%f*",j)))
			AA[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lnx)
			
			A7 = A7 \ AA
			b7 = b7 \ J(N,1,0)
		}
		A7 = -A7


		     class LinearProgram scalar lp  
		     lp = LinearProgram()  
			if(maxiter!=-1){
				lp.setMaxiter(maxiter)
			}
			if (tol!=-1){
			    lp.setTol(tol)
			}
			 lp.setCoefficients(c)
			 lp.setInequality(A1\A5\A6\A7,b1\b5\b6\b7)
			 lp.setEquality(A2\A4,b2\b4)
	         //temp = lp.getInequality() \ lp.getEquality()
             lp.setMaxOrMin("min") // 最小化
			 theta=lp.optimize()
			 beta=lp.parameters()
			 st_matrix("r(beta)",beta)
			 st_view(dsvalue=.,.,"Dv",touse)
			 dsvalue[.,.] = exp(data*beta')
			

}

/////////////////////////////////////////

void function  odf_lp(string scalar varsdata,
                      string scalar touse,
					  real   scalar nx, 
					  real   scalar ny,
					  real   scalar nb,
					  real   scalar maxiter,
					  real   scalar tol)
{
		data = st_data(.,varsdata,touse)
		names= "_Cons", tokens(st_local("varsname")) // 变量对应名称
		nid = 1..length(names)

		N=rows(data)
        data = J(N,1,1),data

		c=colsum(data) //目标函数

		// 第一个约束： lnD<=0
		A1 = data
		b1 = J(N,1,0)

		//第二个约束：\sum(beta_m) =1
		A2 = J(1,length(c),0)
		selectid = select(nid,strpos(names,"y."):+strpos(names,"b."))
		A2[selectid]=J(1,length(selectid),1)
		b2=1

		//第三个约束： \sum(beta_mm)=0
		A4 = J(1,length(c),0)
		selectid = select(nid,strpos(names,"y*")+strpos(names,"b*")+strpos(names,"yb")+ustrregexm(names,"y(\d)_"))
		A4[selectid]=J(1,length(selectid),1)
		b4 = 0

		//第四个约束： sum(\delta_pm)=0
		for(j=1;j<=nx;j++){
			AA = J(1,length(c),0)
			//selectid = select(nid,strpos(names,sprintf("x%f",j)):*(strpos(names,"xy"):+strpos(names,"xb")))
			selectid = select(nid,strpos(names,sprintf("x%fy",j)):+strpos(names,sprintf("x%fb",j)))
			AA[selectid]=J(1,length(selectid),1)
			A4 = A4 \ AA
			b4 = b4 \ 0
		}

		//时间t(y b)的约束：sum(\eta_ty)+sum(\eta_tb)=0
		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,"ty")),select(nid,strpos(names,"tb"))  
		if(length(selectid)>0){
			AA[selectid]=J(1,length(selectid),1)
			A4 = A4 \ AA
			b4 = b4 \ 0
		}			

		//第5个约束：partial lnD / partial lnY >=0
		A5 = J(N,length(c),0)
		selectid = select(nid,strpos(names,"y.1."))
		A5[.,selectid]=J(N,1,1)
		lny = data[.,selectid]
		data2=data
		data2[.,select(1..length(names),strpos(names,"y*"))]=data2[.,select(1..length(names),strpos(names,"y*"))]*2
		//selectid = select(nid,strpos(names,"y1_")),select(nid,strpos(names,"y*1*"))
		//selectid = selectid,select(nid,strpos(names,"y1x")),select(nid,strpos(names,"y1b"))
		selectid = select(nid,ustrregexm(names,"y1[^0-9]")),select(nid,strpos(names,"y*1*"))
		A5[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lny)
		b5 = J(N,1,0)
		//A5 = -A5
		for(j=2;j<=ny;j++){
			AA = J(N,length(c),0)
			selectid = select(nid,strpos(names,sprintf("y.%f.",j)))
			AA[.,selectid]=J(N,1,1)
			lny = data[.,selectid]
			//selectid = select(nid,strpos(names,sprintf("y%f_",j))),select(nid,strpos(names,sprintf("y*%f*",j)))
			//selectid = selectid,select(nid,strpos(names,sprintf("y%fx",j))),select(nid,strpos(names,sprintf("y%fb",j)))
			selectid = select(nid,ustrregexm(names,sprintf("y%f[^0-9]",j))),select(nid,strpos(names,sprintf("y*%f*",j)))
			AA[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lny)	
			//A5  = A5 \ -AA
			A5  = A5 \ AA
			b5 = b5 \ J(N,1,0)
		}

		A5 = -A5

		//第6个约束：partial lnD / partial lnB <=0
		A6 = J(N,length(c),0)
		selectid = select(nid,strpos(names,"b.1."))
		A6[.,selectid]=J(N,1,1)
		lnb = data[.,selectid]
		data2=data
		data2[.,select(1..length(names),strpos(names,"b*"))]=data2[.,select(1..length(names),strpos(names,"b*"))]*2
		//selectid =select(nid,strpos(names,"b1_")),select(nid,strpos(names,"b*1*"))
		//selectid =selectid,select(nid,strpos(names,"b1x")),select(nid,strpos(names,"b1y"))
		selectid = select(nid,ustrregexm(names,"b1[^0-9]")),select(nid,strpos(names,"b*1*"))
		A6[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lnb)
		b6 = J(N,1,0)

		for(j=2;j<=nb;j++){
			AA = J(N,length(c),0)
			selectid = select(nid,strpos(names,sprintf("b.%f.",j)))
			AA[.,selectid]=J(N,1,1)
			lnb = data[.,selectid]
			//selectid = select(nid,strpos(names,sprintf("b%f_",j))),select(nid,strpos(names,sprintf("b*%f*",j)))
            //selectid =selectid,select(nid,strpos(names,sprintf("b%fx",j))),select(nid,strpos(names,sprintf("b%fy",j)))	
			selectid = select(nid,ustrregexm(names,sprintf("b%f[^0-9]",j))),select(nid,strpos(names,sprintf("b*%f*",j)))
			AA[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lnb)	
			A6  = A6 \ AA	
			b6 = b6 \ J(N,1,0)
		}


		     class LinearProgram scalar lp  
		     lp = LinearProgram()  
			if(maxiter!=-1){
				lp.setMaxiter(maxiter)
			}
			if (tol!=-1){
			    lp.setTol(tol)
			}

			 lp.setCoefficients(c)
			 lp.setInequality(A1\A5\A6,b1\b5\b6)
			 lp.setEquality(A2\A4,b2\b4)
	         //temp=((A2\A4),(b2\b4)) \ ((A1\A5\A6),(b1\b5\b6))
			 
			 theta=lp.optimize()
			 beta=lp.parameters()
			 st_matrix("r(beta)",beta)
			 st_view(dsvalue=.,.,"Dv",touse)
			 dsvalue[.,.] = exp(data*beta')

}
/////////////////////////////////////////////////////

void function  ddf_lp(string scalar varsdata,
                      string scalar touse,
					  real   scalar nx, 
					  real   scalar ny,
					  real   scalar nb,
					  real   scalar maxiter,
					  real   scalar tol)
{
		data = st_data(.,varsdata,touse)
		names= "_Cons", tokens(st_local("varsname")) // 变量对应名称
		nid = 1..length(names)

		N=rows(data)
        data = J(N,1,1),data

		c=colsum(data) //目标函数

		// 第一个约束： lnD>=0
		A1 = -data  //将>=转换为<=
		b1 = J(N,1,0)

		//第二个约束：\sum(beta_m)-\sum(gamma_j) =-1
		A2 = J(1,length(c),0)
		selectid = select(nid,strpos(names,"y."))
		A2[selectid]=J(1,length(selectid),1)
		selectid = select(nid,strpos(names,"b."))
		A2[selectid]=J(1,length(selectid),-1)		
		b2=-1

		//第三个约束： 0.5*\sum(beta_mm')+0.5*\sum(gamma_mm')-\sum(u_mj)=0
		A3 = J(1,length(c),0)
		selectid = select(nid,strpos(names,"y*")+strpos(names,"b*"))
		A3[selectid]=J(1,length(selectid),0.5)
		selectid = select(nid,strpos(names,"_y")+strpos(names,"_b")) // ym1_ym2 bj1_bj2
		A3[selectid]=J(1,length(selectid),1) // beta_mm' = beta_m'm
		selectid = select(nid,strpos(names,"yb")) //ymbjyb
		A3[selectid]=J(1,length(selectid),-1)
		b3 = 0

		//第四个约束： sum(u_nm)-sum(u_nj)=0 for any n
		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,"x1y")) //x1ym
		AA[selectid]=J(1,length(selectid),1)
		selectid = select(nid,strpos(names,"x1b")) //x1bj
		AA[selectid]=J(1,length(selectid),-1)		
		A4 =  AA
		b4 =  0
		for(j=2;j<=nx;j++){
			AA = J(1,length(c),0)
			selectid = select(nid,strpos(names,sprintf("x%fy",j)))
			AA[selectid]=J(1,length(selectid),1)
			selectid = select(nid,strpos(names,sprintf("x%fb",j)))
			AA[selectid]=J(1,length(selectid),-1)	
			A4 = A4 \ AA
			b4 = b4 \ 0
		}

		//第5个约束：sum(beta_mm')-sum(u_mj)=0 for any m
		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,"y1_y"):+strpos(names,"y*1*")) //ym1_ym2 y*m*
		AA[selectid]=J(1,length(selectid),1)
		selectid = select(nid,strpos(names,"y1b")) //ymbjyb
		AA[selectid]=J(1,length(selectid),-1)		
		A5 =  AA
		b5 =  0
		for(j=2;j<=ny;j++){
		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,sprintf("y%f_y",j)):+strpos(names,sprintf("y*%f*",j)))
		AA[selectid]=J(1,length(selectid),1)
		selectid = select(nid,strpos(names,sprintf("y%fb",j)))
		AA[selectid]=J(1,length(selectid),-1)		
			A5 = A5 \ AA
			b5 = b5 \ 0
		}

		//第6个约束：sum(gama_jj')-sum(u_mj)=0 for any j
		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,"b1_b"):+strpos(names,"b*1*")) //bj1_bj2 b*j*
		AA[selectid]=J(1,length(selectid),1)
		selectid = select(nid,strpos(names,"b1y")) //ymbjyb
		AA[selectid]=J(1,length(selectid),-1)		
		A6 =  AA
		b6 =  0
		for(j=2;j<=ny;j++){
		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,sprintf("b%f_b",j)):+strpos(names,"b*1*"))
		AA[selectid]=J(1,length(selectid),1)
		selectid = select(nid,strpos(names,sprintf("b%fy",j)))
		AA[selectid]=J(1,length(selectid),-1)		
			A6 = A6 \ AA
			b6 = b6 \ 0
		}

		//时间t(y -b)的约束：sum(\eta_ty)-sum(\eta_tb)=0
		AA = J(1,length(c),0)
		selectid = select(nid,strpos(names,"ty"))  
		if(length(selectid)>0){
			AA[selectid]=J(1,length(selectid),1)
			selectid = select(nid,strpos(names,"tb"))  
			AA[selectid]=J(1,length(selectid),-1)
			A6 = A6 \ AA
			b6 = b6 \ 0
		}



		//第7个约束：partial lnD / partial lnY <=0

		A7 = J(N,length(c),0)
		selectid = select(nid,strpos(names,"y.1.")) //ym
		A7[.,selectid]=J(N,1,1)
		lny = data[.,selectid]
		data2=data
		data2[.,select(1..length(names),strpos(names,"y*"))]=data2[.,select(1..length(names),strpos(names,"y*"))]*2 //ym^2
		//selectid = select(nid,strpos(names,"y1_")),select(nid,strpos(names,"y*1*")) // ym*ym' ym^2 xnym ymbj
		//selectid = selectid, select(nid,strpos(names,"y1x")),select(nid,strpos(names,"y1b")) // ym*ym' ym^2 xnym ymbj
		selectid = select(nid,ustrregexm(names,"y1[^0-9]")),select(nid,strpos(names,"y*1*"))		
		A7[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lny)
		b7 = J(N,1,0)
		for(j=2;j<=ny;j++){
			AA = J(N,length(c),0)
			selectid = select(nid,strpos(names,sprintf("y.%f.",j)))
			AA[.,selectid]=J(N,1,1)
			lny = data[.,selectid]
			//selectid = select(nid,strpos(names,sprintf("y%f_",j))),select(nid,strpos(names,sprintf("y*%f*",j)))
			//selectid =selectid, select(nid,strpos(names,sprintf("y%fx",j))),select(nid,strpos(names,sprintf("y%fb",j)))
			selectid = select(nid,ustrregexm(names,sprintf("y%f[^0-9]",j))),select(nid,strpos(names,sprintf("y*%f*",j)))
			AA[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lny)	
			//A5  = A5 \ -AA
			A7  = A7 \ AA
			b7 = b7 \ J(N,1,0)
		}


		//第8个约束：partial lnD / partial lnB >=0
		A8 = J(N,length(c),0)
		selectid = select(nid,strpos(names,"b.1.")) //bj
		A8[.,selectid]=J(N,1,1)
		lnb = data[.,selectid]
		data2=data
		data2[.,select(1..length(names),strpos(names,"b*"))]=data2[.,select(1..length(names),strpos(names,"b*"))]*2 //bj^2
		//selectid = select(nid,strpos(names,"b1_")),select(nid,strpos(names,"b*1*")) // bj*bj'  bj^2 xnbj ymbj
		//selectid = selectid,select(nid,strpos(names,"b1x")),select(nid,strpos(names,"b1y")) // bj*bj'  bj^2 xnbj ymbj
		selectid = select(nid,ustrregexm(names,"b1[^0-9]")),select(nid,strpos(names,"b*1*"))
		A8[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lnb)
		b8 = J(N,1,0)

		for(j=2;j<=nb;j++){
			AA = J(N,length(c),0)
			selectid = select(nid,strpos(names,sprintf("b.%f.",j)))
			AA[.,selectid]=J(N,1,1)
			lnb = data[.,selectid]
			//selectid = select(nid,strpos(names,sprintf("b%f_",j))),select(nid,strpos(names,sprintf("b*%f*",j)))
			//selectid =selectid,select(nid,strpos(names,sprintf("b%fx",j))),select(nid,strpos(names,sprintf("b%fy",j)))
			selectid = select(nid,ustrregexm(names,sprintf("b%f[^0-9]",j))),select(nid,strpos(names,sprintf("b*%f*",j)))
			AA[.,selectid] = data2[.,selectid]:/J(1,length(selectid),lnb)	
			A8  = A8 \ AA	
			b8 = b8 \ J(N,1,0)
		}
        
		A8 = -A8 // 将>=变成 <=

		     class LinearProgram scalar lp  
		     lp = LinearProgram()  
			if(maxiter!=-1){
				lp.setMaxiter(maxiter)
			}
			if (tol!=-1){
			    lp.setTol(tol)
			}			 
			 lp.setCoefficients(c)
			 lp.setInequality(A1\A7\A8,b1\b7\b8)
			 lp.setEquality(A2\A3\A4\A5\A6,b2\b3\b4\b5\b6)
	         //temp=((A2\A4),(b2\b4)) \ ((A1\A5\A6),(b1\b5\b6))
			 //temp = lp.getInequality() \ lp.getEquality() 
			 lp.setMaxOrMin("min")
			 theta=lp.optimize()
			 beta=lp.parameters()
			 st_matrix("r(beta)",beta)
			 st_view(dsvalue=.,.,"Dv",touse)
			 dsvalue[.,.] = data*beta'

}



end
