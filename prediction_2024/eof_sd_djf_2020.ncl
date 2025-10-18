
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
;latS   =  40
;latN   =  75
;lonL   =  20
;lonR   =  130

latS   =  45
latN   =  75
lonL   =  20
lonR   =  130

yrStrt = 1991
yrLast = 2020

tstart= 35
tend=466
varname1     = "winter_anom"
decomposition_season="JFM"

var     = "sst"
unit= ""
files_dir    = "/disk1/fhd/winter_forecast/data/sd_in11_6mon_wina_sys51.nc"                            ; input directory
varible_file      = addfile (files_dir, "r")
   
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "eof_sd_djf_sys51"                       ; set plot name 
pltType = "pdf"

output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName = "eof_sd_djf_sys51.nc"  

neof   = 1        ; number of EOFs
optEOF = True
optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

optETS = False

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

   var1=varible_file->$varname1$
   

   ensemble_winter=dim_avg_n(var1,1)
   copy_VarCoords(var1(:,0,:,:), ensemble_winter)

   ensemble_winter = dtrend_msg_n(ensemble_winter&nyear,ensemble_winter,True,False,0)

   
   
  
   sea_variable =ensemble_winter(:,{latS:latN},{lonL:lonR})
   

; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
rad    = 4.*atan(1.)/180.
clat   = sea_variable&latitude
clat   = sqrt( cos(rad*clat) )                

; =================================================================
; weight all observations
; =================================================================
wsea_variable   = sea_variable                                   ; copy meta data
wsea_variable   = sea_variable*conform(sea_variable, clat, 1)

; =================================================================
; Reorder (lat,lon,time) the *weighted* input data
; Access the area of interest via coordinate subscripting
; =================================================================
x     = wsea_variable({latitude|:},{longitude|:},nyear|:)
eof      = eofunc_Wrap(x, neof, optEOF)
;eof(0,:,:)=eof(0,:,:)*-1
;eof(2,:,:)=eof(2,:,:)*-1
printVarSummary( eof ) 
printVarSummary( x )

eof_ts   = eofunc_ts_Wrap (x, eof, optETS)


;ee=eofunc_ts_Wrap (x, eof(0:1,:,:), optETS)


printVarSummary( eof )                         ; examine EOF variables
printVarSummary( eof_ts )



; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================
dimx  = dimsizes( x )
mln    = dimx(1)
sumWgt = mln*sum(clat)
eof_ts = eof_ts/sumWgt
eof_ts = dim_standardize_Wrap(eof_ts,0)
;print(eof_ts)
;exit()
;eof(0,:,:)=eof(0,:,:)*-1
;eof_ts(0,:)=eof_ts(0,:)*-1



;*******************************************
; North significance test: any pcvar, eval_transpose, eval can be used
;*******************************************
  
  dimp   = dimsizes(sea_variable)
  ntim   = dimp(0)                                            ; max # eigenvalues possible
  
  prinfo = True
  sig    = eofunc_north(eof@pcvar, ntim, prinfo) 
  print(sig)     


 system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->eof_ts=eof_ts(0,:)
 fout->eof=eof(0,:,:)
 
;;emi 
;e=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc","r")
;emi=e->emi
;nino=e->nino34
;cor_emi=escorc(emi, eof_ts)
;cor_nino34=escorc(nino, eof_ts)
;print(cor_emi)
;print(cor_nino34)


fout1=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m_in11_sys51.nc", "r")
scand_obs=fout1->eof_ts
pc3_t2m=escorc(scand_obs(2,:), eof_ts)
print(pc3_t2m)

pc4_t2m=escorc(scand_obs(3,:), eof_ts)
print(pc4_t2m)
exit()

; data = asciiread("/disk1/fhd/winter_forecast/data/emi.monthly.txt",(/1787,8/),"float")
; aa=data(1343:1774,7)     
; aa!0    = "time"
; ;a=abs(a)
; ;VAR=a(::12)      ;nov     
; VAR1=aa(0::12)      ;dec     
; VAR2=aa(1::12)    ;jan
; VAR3=aa(2::12)     ;feb      
; emi_j=(VAR1+VAR2+VAR3)/3
; emi_j=dtrend(emi_j, False)
; japan=escorc_n(emi_j, eof_ts, 0, 1)
; print(japan)


; t2m_pc3_emi=escorc(emi, t2m_eof(2,:))
; print(t2m_pc3_emi)



; iod_sd=addfile("/disk1/fhd/winter_forecast/data/iodmi_sdi_djf_prd.nc", "r")
; iodmi=iod_sd->iodmii
; sdi=iod_sd->sdi
; iod_t2m=escorc_n(iodmi, t2m_eof, 0, 1)
; sd_t2m=escorc_n(sdi, t2m_eof, 0, 1)
; print(iod_t2m)
; print(sd_t2m)


; iod_sst=escorc_n(iodmi, eof_ts, 0, 1)
; sd_sst=escorc_n(sdi, eof_ts, 0, 1)
; print(iod_sst)
; print(sd_sst)

; prdemi_iodmi=escorc(emi, iodmi)
; prdemi_nino34=escorc(emi, nino)
; print(prdemi_iodmi)
; print(prdemi_nino34)


;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
gsn_define_colormap(wks,"BlRe")       ; choose colormap
plot = new(neof,graphic)                ; create graphic array
; only needed if paneling
; EOF patterns

res                      = True
res@gsnDraw              = False        ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@gsnSpreadColors      = True         ; spread out color table
res@gsnAddCyclic         = False        ; plotted dataa are not cyclic

res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
res@mpMinLonF            = lonL
res@mpMaxLonF            = lonR

res@cnFillOn             = True         ; turn on color fill
res@cnLinesOn            = False        ; True is default
;res@cnLineLabelsOn       = False        ; True is default
res@cnFillPalette        = "BlWhRe"     ; set color map
res@lbLabelBarOn         = False        ; turn off individual lb's
;res@vpHeightF            = 2       ; Changes the aspect ratio
;res@vpWidthF             = 0.85
; res@mpCenterLonF         = 180.
res@tmYLLabelFontHeightF      =0.020  ;
res@tmXBLabelFontHeightF      = 0.020
res@gsnLeftStringFontHeightF  = 0.01
res@gsnRightStringFontHeightF  = 0.01


; res@cnMinLevelValF       = -0.08             ; set min contour level
; res@cnMaxLevelValF       =  0.08           ; set max contour level
; res@cnLevelSpacingF      =  0.01              ; set contour spacing

; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar


resP@txString            =""

;*******************************************
; first plot
;*******************************************
do n=0,neof-1
res@gsnLeftString  = "EOF "+(n+1)
res@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
plot(n)=gsn_csm_contour_map(wks,eof(n,:,:),res)
end do
gsn_panel(wks,plot,(/neof,1/),resP)     ; now draw as one plot

;*******************************************
; second plot
;*******************************************
; EOF time series  [bar form]

rts           = True
rts@gsnDraw   = False       ; don't draw yet
rts@gsnFrame  = False       ; don't advance frame yet
rts@gsnScale  = True        ; force text scaling

; these four rtsources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

rts@vpHeightF = 0.40        ; Changes the aspect ratio
rts@vpWidthF  = 0.85
rts@vpXF      = 0.10        ; change start locations
rts@vpYF      = 0.75        ; the plot


rts@tiYAxisString = "unit:degC"                    ; y-axis label

rts@gsnYRefLine           = 0.              ; reference line
rts@gsnXYBarChart         = True            ; create bar chart
rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

; panel plot only resources
rtsP                      = True            ; modify the panel plot
rtsP@gsnMaximize          = True            ; large format
rtsP@txString             = var +decomposition_season +yrStrt+"-"+yrLast
; polyline parameters used on both plots
;*********************************
polyres                  = True
polyres@gsLineThicknessF = 3.0

year = ispan(1981,2016,1)

; create individual plots
plotb = new(neof,graphic)                ; create graphic array
plota=new(neof,graphic)
do n=0,neof-1
rts@gsnLeftString  = "EOF "+(n+1)
rts@gsnRightString = sprintf("%5.1f", eof@pcvar(n)) +"%"
plotb(n) = gsn_csm_xy (wks,year,eof_ts(n,:),rts)
;plota(n)=gsn_add_polyline(wks,plotb(n),year,y(n,:),polyres)
end do
;draw(plotb)
gsn_panel(wks,plotb,(/neof,1/),rtsP)     ; now draw as one plot


;printVarSummary(eof)

end



