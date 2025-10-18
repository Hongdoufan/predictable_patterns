
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  40
latN   =  70
lonL   =  0
lonR   =  180
yrStrt = 1981
yrLast = 2016
tstart = 35
tend   = 466
varname1     = "winter_anom"
decomposition_season="JFM"
season="JFM"
nrc=3
var     = "t2m"
unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "cv_matrix_1out1.nc" 

;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "obs2_multireg"                       ; set plot name 
pltType = "pdf" 
year=ispan(1981,2016,1)
nyear=35
;   opt = False
;   opt@print_anova = False     ; optional
;   opt@print_data  = False
nfactors= 5
   
;==========================================================
;read predicable patterns
;==========================================================
all_files = "/disk1/fhd/winter_forecast/data/msn_t2m_cv.nc"
patterns = addfile (all_files, "r")
;---Read "pottmp" in "join" mode and print a summary of the variable

   mode=patterns->msn_t2m(:,:,{latS:latN},{lonL:lonR})  ; note syntax [:]
   printVarSummary(mode) 
   lat=mode&latitude
   lon=mode&longitude
   mlat=dimsizes(lat)
   mlon=dimsizes(lon)

tren=addfile("/disk1/fhd/degreepaper/data/eof_t2m_leave_obs.nc","r")
trend=tren->eof(:,1,{latS:latN},{lonL:lonR})
trend=trend*7.

;t=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")
;pc1=t->eof_ts
;tren=addfile("/disk1/fhd/winter_forecast/data/cv_trend_obs1.nc","r")
;trend=tren->slope(:,{20:89},{0:360})

;pc2=tren->eof_ts(:,1,:)
printVarSummary(trend)
;exit()

;==========================================================
;read predictors 
;==========================================================
;t2m_eof=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc","r")
sic_pc=addfile("/disk1/fhd/winter_forecast/data/sic_projection_index_cv2.nc","r")
ea_pc=addfile("/disk1/fhd/winter_forecast/data/sdea_projection_index_cv.nc","r")
sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/sd_projection_index_cv1.nc","r")
e=addfile("/disk1/fhd/winter_forecast/data/sst_projection_index_cv.nc","r")
t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_cv.nc","r")
;t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_eof2_cv.nc","r")
;t2m_avg=addfile("/disk1/fhd/winter_forecast/data/trend_prd_projection_index.nc", "r")
;t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_cv_prdtrend1.nc","r")
;t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_cv_obstrend.nc","r")

pc1=t2m_avg->mpc1
;pc1=fspan(1,36,36)
pc1!0 = "time"
;printVarSummary(pc1)
;pc1=dim_standardize_n(pc1,1,0)
nino=e->nino
emi=e->emi
sic=sic_pc->sic*-1.
ea=ea_pc->sd

sd_ea=sd_ea_pc->sd
sic!0 = "time"

;==========================================================
; read observation
;==========================================================      = ispan(1980,2008,1)
 
ff=addfile("/disk1/fhd/data/t2m.mon.mean.1.0.nc","r")
TIME2   = ff->time
YYYY2   = cd_calendar(TIME2,-2)/100                 
air= short2flt(ff->t2m(35:466,{latS:latN},{lonL:lonR}))

  obs = month_to_season (air, season)
  obs_cli=dim_avg_n(obs,0)
   winter_anom=new((/36,dimsizes(lat),dimsizes(lon)/),"float")
   do i=0,35
   winter_anom(i,:,:)=obs(i,:,:)-obs_cli
   end do   
   copy_VarCoords(obs, winter_anom)
 
;==========================================================
; leave 1981 out    the first group
;==========================================================      = ispan(1980,2008,1)
;printVarSummary(varible_file)


   xp1   = new( (/nfactors,nyear/), typeof(pc1))
   xp1(0,:) = pc1(1:35)
   xp1(1,:) = nino(1:35)
   xp1(2,:) = sd_ea(1:35)
   xp1(3,:) = sic(1:35)
   xp1(4,:) = ea(1:35)



   pattern1=new((/nfactors,nyear,dimsizes(lat),dimsizes(lon)/),"float")
   pattern1(0,:,:,:)=trend(1:35,:,:)
   pattern1(1,:,:,:)=mode(1:35,1,:,:)
   pattern1(2,:,:,:)=mode(1:35,2,:,:)
   pattern1(3,:,:,:)=mode(1:35,3,:,:)
   pattern1(4,:,:,:)=mode(1:35,3,:,:)


   reforecast1=new((/nfactors,nyear,dimsizes(lat),dimsizes(lon)/),"float")

do i=0,nyear-1
   reforecast1(0,i,:,:)=pattern1(0,i,:,:)*xp1(0,i)
   reforecast1(1,i,:,:)=pattern1(1,i,:,:)*xp1(1,i)
   reforecast1(2,i,:,:)=pattern1(2,i,:,:)*xp1(2,i)
   reforecast1(3,i,:,:)=pattern1(3,i,:,:)*xp1(3,i)
   reforecast1(4,i,:,:)=pattern1(4,i,:,:)*xp1(4,i)   
end do
;   exit()
   R1   = new( (/nfactors/), typeof(pc1))
   r1   = new( (/nfactors,nfactors/), typeof(pc1))
   OBS1=winter_anom(1:35,:,:)
   R1_1=transpose(reshape(OBS1,(/nyear,mlat*mlon/)))
   R1_2=reshape(reforecast1,(/nfactors,nyear,mlat*mlon/))
   R1(0)=xp1(0,:)#R1_2(0,:,:)#R1_1#xp1(0,:)  ;   R(0)
   R1(1)=xp1(1,:)#R1_2(1,:,:)#R1_1#xp1(1,:)  ;   R(0)
   R1(2)=xp1(2,:)#R1_2(2,:,:)#R1_1#xp1(2,:)  ;   R(0)
   R1(3)=xp1(3,:)#R1_2(3,:,:)#R1_1#xp1(3,:)  ;   R(0)
   R1(4)=xp1(4,:)#R1_2(4,:,:)#R1_1#xp1(4,:)  ;   R(0)
   
do i=0,nfactors-1
   do j=0,nfactors-1
      
   r1(i,j)=xp1(i,:)#R1_2(i,:,:)#(transpose(R1_2(j,:,:)))#xp1(i,:)
   
   end do
end do
   printVarSummary(R1)
   printVarSummary(r1)


;   print(R)
;   print(r)

;x=(inverse_matrix(r))#R
;print(x)
;==========================================================
; leave 2016 out    the last group
;==========================================================      = ispan(1980,2008,1)
;printVarSummary(varible_file)


   xp36   = new( (/nfactors,nyear/), typeof(pc1))
   xp36(0,:) = pc1(0:34)
   xp36(1,:) = nino(0:34)
   xp36(2,:) = sd_ea(0:34)
   xp36(3,:) = sic(0:34)
   xp36(4,:) = ea(0:34)



   pattern36=new((/nfactors,nyear,dimsizes(lat),dimsizes(lon)/),"float")
   pattern36(0,:,:,:)=trend(0:34,:,:)
   pattern36(1,:,:,:)=mode(0:34,1,:,:)
   pattern36(2,:,:,:)=mode(0:34,2,:,:)
   pattern36(3,:,:,:)=mode(0:34,3,:,:)
   pattern36(4,:,:,:)=mode(0:34,3,:,:)


   reforecast36=new((/nfactors,nyear,dimsizes(lat),dimsizes(lon)/),"float")

do i=0,nyear-1
   reforecast36(0,i,:,:)=pattern36(0,i,:,:)*xp36(0,i)
   reforecast36(1,i,:,:)=pattern36(1,i,:,:)*xp36(1,i)
   reforecast36(2,i,:,:)=pattern36(2,i,:,:)*xp36(2,i)
   reforecast36(3,i,:,:)=pattern36(3,i,:,:)*xp36(3,i)
   reforecast36(4,i,:,:)=pattern36(4,i,:,:)*xp36(4,i)   
end do
;   exit()
   R36   = new( (/nfactors/), typeof(pc1))
   r36   = new( (/nfactors,nfactors/), typeof(pc1))
   OBS36=winter_anom(1:35,:,:)
   R36_1=transpose(reshape(OBS36,(/nyear,mlat*mlon/)))
   R36_2=reshape(reforecast36,(/nfactors,nyear,mlat*mlon/))
   R36(0)=xp36(0,:)#R36_2(0,:,:)#R36_1#xp36(0,:)  ;   R(0)
   R36(1)=xp36(1,:)#R36_2(1,:,:)#R36_1#xp36(1,:)  ;   R(0)
   R36(2)=xp36(2,:)#R36_2(2,:,:)#R36_1#xp36(2,:)  ;   R(0)
   R36(3)=xp36(3,:)#R36_2(3,:,:)#R36_1#xp36(3,:)  ;   R(0)
   R36(4)=xp36(4,:)#R36_2(4,:,:)#R36_1#xp36(4,:)  ;   R(0)
   
do i=0,nfactors-1
   do j=0,nfactors-1
      
   r36(i,j)=xp36(i,:)#R36_2(i,:,:)#(transpose(R36_2(j,:,:)))#xp36(i,:)
   
   end do
end do
   printVarSummary(R36)
   printVarSummary(r36)


;   print(R)
;   print(r)

;x=(inverse_matrix(r))#R
;print(x)
;==========================================================
; leave   the 2nd-35th group
;==========================================================      = ispan(1980,2008,1)
;printVarSummary(varible_file)

   
;   xp   = new( (/nfactors,nyear/), typeof(pc1))
;   pattern=new((/nfactors,nyear,dimsizes(lat),dimsizes(lon)/),"float")
;   OBS=new((/nyear,dimsizes(lat),dimsizes(lon)/),"float")
;   reforecast=new((/nfactors,nyear,dimsizes(lat),dimsizes(lon)/),"float")

   R_matrix   = new( (/36,nfactors/), typeof(pc1))
   r_matrix   = new( (/36,nfactors,nfactors/), typeof(pc1))

 do testy=1,34
     
   xp   = new( (/nfactors,nyear/), typeof(pc1))
   pattern=new((/nfactors,nyear,dimsizes(lat),dimsizes(lon)/),"float")
   OBS=new((/nyear,dimsizes(lat),dimsizes(lon)/),"float")
   reforecast=new((/nfactors,nyear,dimsizes(lat),dimsizes(lon)/),"float")  
   OBS(0:testy-1,:,:)=winter_anom(0:testy-1,:,:)
   OBS(testy:nyear-1,:,:)=winter_anom(testy+1:nyear,:,:)
  
   xp(0,0:testy-1)=pc1(0:testy-1)
   xp(1,0:testy-1)=nino(0:testy-1)
   xp(2,0:testy-1)=sd_ea(0:testy-1)
   xp(3,0:testy-1)=sic(0:testy-1)
   xp(4,0:testy-1)=ea(0:testy-1)

   xp(0,testy:nyear-1)=pc1(testy+1:nyear)
   xp(1,testy:nyear-1)=nino(testy+1:nyear)
   xp(2,testy:nyear-1)=sd_ea(testy+1:nyear)
   xp(3,testy:nyear-1)=sic(testy+1:nyear)
   xp(4,testy:nyear-1)=ea(testy+1:nyear)

   pattern(0,0:testy-1,:,:)=trend(0:testy-1,:,:)
   pattern(1,0:testy-1,:,:)=mode(0:testy-1,1,:,:)
   pattern(2,0:testy-1,:,:)=mode(0:testy-1,2,:,:)
   pattern(3,0:testy-1,:,:)=mode(0:testy-1,3,:,:)
   pattern(4,0:testy-1,:,:)=mode(0:testy-1,3,:,:)

   pattern(0,testy:nyear-1,:,:)=trend(testy+1:nyear,:,:)
   pattern(1,testy:nyear-1,:,:)=mode(testy+1:nyear,1,:,:)
   pattern(2,testy:nyear-1,:,:)=mode(testy+1:nyear,2,:,:)
   pattern(3,testy:nyear-1,:,:)=mode(testy+1:nyear,3,:,:)
   pattern(4,testy:nyear-1,:,:)=mode(testy+1:nyear,3,:,:)

    do i=0,nyear-1
     reforecast(0,i,:,:)=pattern(0,i,:,:)*xp(0,i)
     reforecast(1,i,:,:)=pattern(1,i,:,:)*xp(1,i)
     reforecast(2,i,:,:)=pattern(2,i,:,:)*xp(2,i)
     reforecast(3,i,:,:)=pattern(3,i,:,:)*xp(3,i)
     reforecast(4,i,:,:)=pattern(4,i,:,:)*xp(4,i)  

    end do
;   exit()
   R   = new( (/nfactors/), typeof(pc1))
   r   = new( (/nfactors,nfactors/), typeof(pc1))
;   R_matrix   = new( (/36,nfactors/), typeof(pc1))
;   r_matrix   = new( (/36,nfactors,nfactors/), typeof(pc1))
   R_1=transpose(reshape(OBS,(/nyear,mlat*mlon/)))
   R_2=reshape(reforecast,(/nfactors,nyear,mlat*mlon/))
   R(0)=xp(0,:)#R_2(0,:,:)#R_1#xp(0,:)  ;   R(0)
   R(1)=xp(1,:)#R_2(1,:,:)#R_1#xp(1,:)  ;   R(0)
   R(2)=xp(2,:)#R_2(2,:,:)#R_1#xp(2,:)  ;   R(0)
   R(3)=xp(3,:)#R_2(3,:,:)#R_1#xp(3,:)  ;   R(0)
   R(4)=xp(4,:)#R_2(4,:,:)#R_1#xp(4,:)  ;   R(0)

   
  do i=0,nfactors-1
   do j=0,nfactors-1
      
   r(i,j)=xp(i,:)#R_2(i,:,:)#(transpose(R_2(j,:,:)))#xp(i,:)
   
   end do
  end do

   R_matrix(testy,:)=R
   r_matrix(testy,:,:)=r
   delete(R) 
   delete(r)
   delete(xp)
   delete(pattern)
   delete(OBS)
   delete(reforecast)
   delete(R_1)
   delete(R_2)
      

end do



   
   R_matrix(0,:)=R1
   r_matrix(0,:,:)=r1
   R_matrix(35,:)=R36
   r_matrix(35,:,:)=r36

   printVarSummary(R_matrix)
   printVarSummary(r_matrix)
   print(R_matrix)

 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->R=R_matrix
 fout->r=r_matrix
 exit()

 


   printVarSummary(R_matrix)
   printVarSummary(r_matrix)
   print(R_matrix)
exit()

   
do i=0,nfactors-1
   do j=0,nfactors-1
      
   r1(i,j)=xp1(i,:)#R1_2(i,:,:)#(transpose(R1_2(j,:,:)))#xp1(i,:)
   
   end do
end do
   printVarSummary(R1)
   printVarSummary(r1)
;   R_1=






x1=new(nyear,typeof(f1))
x2=new(nyear,typeof(f1))
x3=new(nyear,typeof(f1))
x4=new(nyear,typeof(f1))
datab=new((/36,nfactors+1/),"float")  
nfactors=4

;testy=34

 do testy=1,34

 x1(0:testy-1)=f1(0:testy-1)
 x2(0:testy-1)=f2(0:testy-1)
 x3(0:testy-1)=f3(0:testy-1)
 x4(0:testy-1)=f4(0:testy-1)

 x1(testy:nyear-1)=f1(testy+1:nyear)
 x2(testy:nyear-1)=f2(testy+1:nyear)
 x3(testy:nyear-1)=f3(testy+1:nyear)
 x4(testy:nyear-1)=f4(testy+1:nyear)

 y=trend(testy,:)
 nrow=dimsizes(y)

   xp   = new( (/nrow,nfactors/), typeof(x1))  ; create an array to hold predictor variables   
   xp(:,0) = x1
   xp(:,1) = x2
   xp(:,2) = x3
   xp(:,3) = x4
   datab(testy,:)   =  reg_multlin_stats(y,xp,opt)
;   print(ba)
;   datab(testy,:)=ba

   ;print(eee)
 end do
 
 print(datab)
 
 
 
datab!0="leave_year"
datab!1="factor" 
   fit=new((/36/),"float")
   do i=0,35
      fit(i)=datab(i,0)+datab(i,1)*f1(i)+datab(i,2)*f2(i)+datab(i,3)*f3(i)+datab(i,4)*f1(4)
   end do

cor1=escorc(pc2,f1)
cor2=escorc(pc2,fit)
print(cor1)
print(cor2) 

 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->mpc1=fit

 exit()
      
   b=new(36,"float")
   coe=new(36,"float")
   
   coe1 = regCoef(x(1:35),y(1:35))
   b(0)=coe1@yintercept
   coe36 = regCoef(x(0:34),y(0:34))
   b(35)=coe36@yintercept

   coe(0)=coe1
   coe(35)=coe36
   xx=new((/36,35/),typeof(b))
   yy=new((/36,35/),typeof(b))

   do i=1,34   
     xx(i,0:(i-1))=x(0:(i-1))
     xx(i,i:34)=x((i+1):35)
     
     yy(i,0:(i-1))=y(0:(i-1))
     yy(i,i:34)=y((i+1):35)
     printVarSummary(xx)
     printVarSummary(yy)
     coe(i) = regCoef(xx(i,:),yy(i,:))      
     b(i) = coe@yintercept
     
   end do
print(b)
print(coe)


   fit=new((/36/),"float")
   do i=0,35
      fit(i)=b(i)+coe(i)*x(i)
   end do
   
   cor1=escorc(x,y)
   cor2=escorc(fit,y)
   print(cor1)
   print(cor2)

data=new((/4,36/),typeof(b))
data(0,:)=x
data(1,:)=y
;data(2,:)=x*0.084/0.069

jk=escorc(data(1,:),data(2,:))
print(jk)
;exit()
data1=dtrend_n(data,True,1) 
print(data1@slope)  
; exit()
jj1=escorc(data1(0,:),data1(1,:))
jj2=escorc(data1(1,:),data1(2,:))
print(jj1)
print(jj2)


;************************************************
; create plot
;************************************************
wks = gsn_open_wks(pltType,pltDir+pltName)
res               = True                        ; plot mods desired
res@gsnDraw= False
res@gsnFrame= False

res@tmXBMode          = "Explicit"              ; explicit labels
;res@tmXBValues        = x                       ; location of labels
;res@tmXBLabels        = warm_yrs                ; labels themselves
res@tmLabelAutoStride = True                    ; nice stride on labels
;res@xyLineColors      = (/"white","red"/)  ; line colors


res@tiYAxisString    = "  "    ; y-axis label
res@tiMainString      = " "; title
res@vpHeightF = 0.40        ; Changes the aspect ratio
res@vpWidthF  = 0.75


res_text                    = True                  ; text mods desired
res_text@txFontHeightF      = 0.011                 ; change text size
res_text@txJust             = "CenterLeft"          ; text justification
res_lines                   = True                  ; polyline mods desired
res_lines@gsLineDashPattern = 0.                    ; solid line
res_lines@gsLineThicknessF  = 5.                    ; line thicker
; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format


res@tiMainString      = "area-weighted pattern correlation "; title
res@xyLineColors      = (/"red","green","blue","black"/)
res@xyDashPatterns    = (/0.0,0.0,0,0/)        ; line patterns
res@xyLineThicknesses =(/5.0,5.0,5,5/) 
;res@xyDashPatterns	 = (/5.,5./)      ; line thicknesses
plota=new(2,graphic)
plota(0)  = gsn_csm_xy(wks,year,data1,res)
;plota(1)  = gsn_csm_xy(wks,year,data,res)
;xx = (/1981,1984/)
;yy = (/0.54,0.54/)
;res_lines@gsLineColor       = "red"
;abbcd=new(4,graphic)
;abbcd(0) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
;res_lines@gsLineColor       = "green"
;yy = (/0.5,0.5/)
;abbcd(1) = gsn_add_polyline(wks,plota,xx,yy,res_lines)                ; add polyline
;res_lines@gsLineColor       = "blue"
;yy = (/0.46,0.46/)
;abbcd(2) = gsn_add_polyline(wks,plota,xx,yy,res_lines)
;res_lines@gsLineColor       = "black"
;yy = (/0.42,0.42/)
;abbcd(3) = gsn_add_polyline(wks,plota,xx,yy,res_lines)
;
;dum6q = gsn_add_text(wks,plota,"dec 0.82",1985,0.54,res_text) ; add text
;dum6q = gsn_add_text(wks,plota,"jan 0.51",1985,0.5,res_text) ; add text
;dum6q = gsn_add_text(wks,plota,"feb 0.76",1985,0.46,res_text) ; add text
;dum6q = gsn_add_text(wks,plota,"winter",1985,0.42,res_text) ; add text


gsn_panel(wks,plota,(/1,1/),resP)     ; now draw as one plot



end


