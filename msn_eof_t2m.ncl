
begin
; ==============================================================
; User defined parameters that specify region of globe and years et
; ==============================================================
latS   =  20
latN   =  89
lonL   =  0
lonR   =  360
var     = "t2m"
files_dir    = "/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina.nc"                            ; input directory
neof   = 30        ; number of EOFs
eofp   = 4           ;number of eof being plotted

yrStrt = 1981
yrLast = 2016
nyear=36
nensemble=25
tstart= 35
tend=466
varname1     = "winter_anom"
decomposition_season="DJF"
label1= (/"(a)","(c)","(e)","(g)"/)
label2= (/"(b)","(d)","(f)","(h)"/)

unit= ""
varible_file      = addfile (files_dir, "r")
   
;   level   =  17                                        ; 300hPa
PLOT    = True                            ; create a plot [?]
pltDir  =  "/disk1/fhd/winter_forecast/result/"                            ; directory for plot output
pltName = "msn_eof_"+var                       ; set plot name 
pltType = "ps" 


optEOF = True
optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired
optETS = False

; ==============================================================
; compute deviations from ensemble mean and perform EOF to them 
; to extract internal variations
; ==============================================================

   var1=varible_file->$varname1$
   ; Opt                = True
   ; Opt@ForceOverwrite = True
   ; Opt@DstGridType    = "2.5x2.5"
   ; Opt@DstLLCorner    = (/ -90,   0/)
   ; Opt@DstURCorner    = (/  90, 357.5/)
   
   ; var1_regrid = ESMF_regrid(var1,Opt)
   ; var1_regrid =var1_regrid(:,:,::-1,:)

   ensemble_winter=dim_avg_n(var1,1)
   nlat=dimsizes(var1&latitude)
   nlon=dimsizes(var1&longitude)

   do i=0,nensemble-1
      var1(:,i,:,:)=var1(:,i,:,:)-ensemble_winter
   end do

   deviation=reshape(var1, (/nyear*nensemble,nlat,nlon/))
   deviation!0="time"
   deviation!1="latitude"
   deviation!2="longitude"
   deviation&time=ispan(0,899,1)
   deviation&latitude=var1&latitude
   deviation&longitude=var1&longitude

   copy_VarCoords(deviation(0,:,:), ensemble_winter(0,:,:))
   ensemble_winter!0="time"
   ensemble_winter&time=ispan(yrStrt,yrLast,1)
   var_winter=deviation(:,{latS:latN},{lonL:lonR})
   area_lat=var_winter&latitude

; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
rad    = 4.*atan(1.)/180.
clat   = area_lat
clat   = sqrt( cos(rad*clat) )                


; =================================================================
; weight all observations
; =================================================================
wsea_variable   = var_winter                                  ; copy meta data
wsea_variable   = var_winter*conform(var_winter, clat, 1)
;wsea_variable@long_name = "Wgt: "+sea_variable@long_name


x     = wsea_variable({latitude|:},{longitude|:},time|:)
eof      = eofunc_Wrap(x, neof, optEOF)
; =================================================================
; project the ensemble mean onto the EOFs of noise and 
; conduct a SVD on the prewhitened ensemble mean 
; =================================================================
x_winter=ensemble_winter({latitude|:},{longitude|:},time|:)
xx_winter=x_winter({latS:latN},{lonL:lonR},:)
xm_   = eofunc_ts_Wrap (xx_winter, eof, optETS)
xm_copy = xm_

  nra = neof      ; number rows    of matrix 'a'
  nca = nyear       ; number columns
  a   = transpose(xm_)  ; reshape to 2D 
  u   = new ( (/nca,nra/) , typeof(a) )  ; pre-allocate space 
  v   = new ( (/nca,nca/) , typeof(a) )  ; for returned arrays

  s   = svd_lapack (a, "S" , "S", 0,  u, v)  ; transpose(V)
 ; print(v)

;;=================================================================
; Obtained the time series of MSN EOF and each member(noise) 
; by projecting ensemble mean or each member onto spatial filters 
; =================================================================
mlat=dimsizes(eof&latitude)
mlon=dimsizes(eof&longitude)
eof_1=eof({latitude|:},{longitude|:},evn|:)
dev_eof=transpose(reshape(eof,(/neof,mlat*mlon/)))
filter_vector=dev_eof#(transpose(u(0:(neof-1),:)))
filter_re=reshape(filter_vector,(/mlat,mlon,neof/))
copy_VarCoords(eof_1, filter_re)
filter_r=filter_re(evn|:,{latitude|:},{longitude|:})
v_var1=var1({latitude|:},{longitude|:},nyear|:,nensemble|:)
vv_var1=v_var1({latS:latN},{lonL:lonR},:,:)


member_ts=new((/neof,nensemble,nyear/),typeof(filter_r))
y_ff=new((/neof,nyear/),typeof(filter_r))
msn_original_ts =   eofunc_ts_Wrap (xx_winter, filter_r, optETS)
do i=0,nensemble-1
   do j=0,neof-1
      y_ff= eofunc_ts_Wrap (vv_var1(:,:,:,i), filter_r, optETS)
      member_ts(j,i,:)=y_ff(j,:) 
   end do
end do

member_ts!1="nensemble"
member_ts&nensemble=ispan(0,24,1)
;;=================================================================
; Normalize time series: Sum spatial weights over the area of used
; Acquire spatial pattern (pattern_re) asscoiated with the dominant forece response
; by prejecting ensemble mean onto time_series(optimized PC)  (pattern_ts)
;=================================================================
  msn_ts = msn_original_ts
  dimx  = dimsizes( x )
  mln    = dimx(1)
  sumWgt = mln*sum(clat)
  msn_ts = msn_ts/sumWgt

  msn_ts = dim_standardize_Wrap(msn_ts,0)
  mlat=dimsizes(eof&latitude)
  mlon=dimsizes(eof&longitude)
  re_ensemble_winter=reshape(xx_winter,(/mlat*mlon,nyear/))

  pattern= re_ensemble_winter#transpose(msn_ts)
  pattern_re  = reshape(pattern,(/mlat,mlon,neof/))
  copy_VarCoords(eof_1, pattern_re)
  
  do i=0,neof-1
     pattern_re(:,:,i)=pattern_re(:,:,i)/s(i)
  end do     
 
  msn_pattern=pattern_re(evn|:,latitude|:,longitude|:)

;;=================================================================
; calculate the explained variance
; =================================================================
  explained_variance=new(neof,"float")
  do i=0,neof-1
     explained_variance(i)=s(i)^2/sum(s^2)
  end do

  print(explained_variance(0:(eofp-1)))
  ;print(s)
;;=================================================================
; Statistical significance of MSN EOF mode
; =================================================================


y_m=msn_original_ts
f=(nensemble*dim_variance_n(y_m, 1))/dim_avg_n((dim_variance_n(member_ts, 1)),1)
;42.4
print("f test values "+f(0:eofp-1))


;;=================================================================
; output
; =================================================================
msn_ts(1,:)=msn_ts(1,:)*-1
msn_pattern(1,:,:)=msn_pattern(1,:,:)*-1


 system("rm -f /disk1/fhd/winter_forecast/data/msn_eof_t2m.nc")
 fout=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "c")
 fout->eof_ts=msn_ts(0:(eofp-1),:)
 fout->eof=msn_pattern(0:(eofp-1),:,:)
;;=================================================================
; 
; =================================================================

; aa=addfile("/disk1/fhd/winter_forecast/data/t2m_eof_prd.nc", "r")
; t2m_eof=aa->eof_ts

; cor=escorc(t2m_eof, msn_ts)
; do i=0,eofp-1 
;    print("pc"+ i +" "+ cor(i,i))
; end do

; e=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc","r")
; nino=e->nino34
; cor_nino=escorc_n(nino, msn_ts(3,:),0,0)
; print(cor_nino)
;exit()
; t2m      = addfile("/disk1/fhd/winter_forecast/data/msn_eof_sst_pacific.nc", "r")
; t2m_eof=t2m->eof_ts
; sst_t2m=escorc(t2m_eof, eof_ts)
; print(sst_t2m)



;obs_ts= eofunc_ts_Wrap (vv_var1(:,:,:,i), msn_pattern, optETS)

;============================================================
; PLOTS
;============================================================
wks = gsn_open_wks(pltType,pltDir+pltName)
gsn_define_colormap(wks,"BlRe")       ; choose colormap
plot = new(eofp,graphic)                ; create graphic array
; only needed if paneling
; EOF patterns

res                      = True
res@gsnDraw              = False        ; don't draw yet
res@gsnFrame             = False        ; don't advance frame yet
res@gsnSpreadColors      = True         ; spread out color table
res@gsnAddCyclic         = True        ; plotted dataa are not cyclic

res@mpFillOn             = False        ; turn off map fill
res@mpMinLatF            = latS         ; zoom in on map
res@mpMaxLatF            = latN
res@mpMinLonF            = lonL
res@mpMaxLonF            = lonR

res@cnFillOn             = True         ; turn on color fill
res@cnLinesOn            = False        ; True is default
res@cnLineLabelsOn       = False        ; True is default
res@cnFillPalette        = "BlWhRe"     ; set color map
res@lbLabelBarOn         = False        ; turn off individual lb's
;res@vpHeightF            = 2       ; Changes the aspect ratio
;res@vpWidthF             = 0.85
res@mpCenterLonF         = 180.
res@tmYLLabelFontHeightF      =0.018  ;
res@tmXBLabelFontHeightF      = 0.018
res@tmXBTickSpacingF        =60

res@gsnLeftStringFontHeightF  = 0.021
res@gsnRightStringFontHeightF  = 0.021

; set symmetric plot min/max
symMinMaxPlt(msn_pattern(0:(eofp-1),:,:), 16, False, res)       ; contributed.ncl

; panel plot only resources
resP                     = True         ; modify the panel plot
resP@gsnMaximize         = True         ; large format
resP@gsnPanelLabelBar    = True         ; add common colorbar
resP@pmLabelBarParallelPosF = 0.03
; resP@pmLabelBarOrthogonalPosF = -0.005
;resP@pmLabels
;resP@pmLabelBarHeightF  =   0
resP@txString            = var+"_"+decomposition_season+" " +yrStrt+"-"+yrLast

 resP@pmLabelBarOrthogonalPosF = -0.02       ; 0.05
 resP@pmLabelBarHeightF    = 0.03
 resP@pmLabelBarWidthF =0.8
 resP@lbLabelFontHeightF  =0.015

;*******************************************
; first plot
;*******************************************
do n=0,eofp-1
res@gsnLeftString  = label1(n)+" MSN EOF"+ (n+1)
res@gsnRightString = sprintf("%5.1f", 100.*explained_variance(n)) +"%"
plot(n)=gsn_csm_contour_map_ce(wks,msn_pattern(n,:,:),res)
end do
gsn_panel(wks,plot,(/eofp,1/),resP)     ; now draw as one plot

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
rts@tmYLLabelFontHeightF      =0.03  ;
rts@tmXBLabelFontHeightF      = 0.03
rts@gsnLeftStringFontHeightF  = 0.04
rts@gsnRightStringFontHeightF  = 0.04


rts@tiYAxisString = "unit: "+"~S~o~N~C"                    ; y-axis label

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
do n=0,eofp-1
rts@gsnLeftString  = label2(n)
rts@gsnRightString = " "
plotb(n) = gsn_csm_xy (wks,year,msn_ts(n,:),rts)
;plota(n)=gsn_add_polyline(wks,plotb(n),year,y(n,:),polyres)
end do
;draw(plotb)
gsn_panel(wks,plotb,(/eofp,1/),rtsP)     ; now draw as one plot


;printVarSummary(eof)

end





