
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
latS   =  0
latN   =  90
lonL   =  0
lonR   =  360
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
outName = "trendpattern_obs.nc" 

;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "obs2_multireg"                       ; set plot name 
pltType = "pdf" 
year=ispan(1981,2016,1)
nyear=35
   opt = False
   opt@print_anova = False     ; optional
   opt@print_data  = False
nfactors= 3
   
  t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_cv.nc","r")
  x=t2m_avg->mpc1

  t=addfile("/disk1/fhd/winter_forecast/data/eof_t2m_obs_eof2.nc","r")
  pc2=t->eof_ts
  
  
sic_pc=addfile("/disk1/fhd/winter_forecast/data/sic_projection_index_cv.nc","r")
sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/sd_projection_index_cv.nc","r")
e=addfile("/disk1/fhd/winter_forecast/data/sst_projection_index_cv.nc","r")
t2m_avg=addfile("/disk1/fhd/winter_forecast/data/mpc1_cv.nc","r")
f1=t2m_avg->mpc1
f2=e->nino
;emi=e->emi
f4=sic_pc->sic
f3=sd_ea_pc->sd

tren=addfile("/disk1/fhd/degreepaper/data/eof_t2m_leave_obs.nc","r")
trend=tren->eof_ts(:,1,:)



x1=new(nyear,typeof(f1))
x2=new(nyear,typeof(f1))
x3=new(nyear,typeof(f1))
x4=new(nyear,typeof(f1))
datab=new((/36,nfactors+1/),"float")  

y1=trend(0,:)
xp1   = new( (/nyear,nfactors/), typeof(x1))
   xp1(:,0) = f1(1:35)
   xp1(:,1) = f2(1:35)
   xp1(:,2) = f3(1:35)

datab(0,:)   =  reg_multlin_stats(y1,xp1,opt)

y36=trend(35,:)
xp2   = new( (/nyear,nfactors/), typeof(x1))
   xp2(:,0) = f1(0:34)
   xp2(:,1) = f2(0:34)
   xp2(:,2) = f3(0:34)

datab(35,:)   =  reg_multlin_stats(y36,xp2,opt)




;testy=34

 do testy=1,34

 x1(0:testy-1)=f1(0:testy-1)
 x2(0:testy-1)=f2(0:testy-1)
 x3(0:testy-1)=f3(0:testy-1)

 x1(testy:nyear-1)=f1(testy+1:nyear)
 x2(testy:nyear-1)=f2(testy+1:nyear)
 x3(testy:nyear-1)=f3(testy+1:nyear)

 y=trend(testy,:)
 nrow=dimsizes(y)

   xp   = new( (/nrow,nfactors/), typeof(x1))  ; create an array to hold predictor variables   
   xp(:,0) = x1
   xp(:,1) = x2
   xp(:,2) = x3
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
      fit(i)=datab(i,0)+datab(i,1)*f1(i)+datab(i,2)*f2(i)+datab(i,3)*f3(i)
   end do

cor1=escorc(pc2,f1)
cor2=escorc(pc2,fit)
print(cor1)
print(cor2) 

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
;


gsn_panel(wks,plota,(/1,1/),resP)     ; now draw as one plot



end
