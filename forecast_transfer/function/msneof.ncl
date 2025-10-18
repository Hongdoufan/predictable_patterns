;===========================================================
; Calculate MSN EOF
; 
;
;*Input data:
;   var   : variable
;   nensemble   : ensemble size
;   latS,latN,lonL,lonR : area    ; the unit should be latitude&longitude
;   nyear  :the years for MSN EOF
;   neof   : the size to extract the noise EOF   
;   eofp   : the size of MSN EOF
;*Output data:
;    out:   MSN EOF 
;    out@time_series : time series
;    out@explained_variance : explained_variance
;    out@f_test : f_test

;*History:
;   2020-04-17: First written by Hongdou Fan of IAP, CAS.
;===========================================================

undef("msn_eof")
function msn_eof(var,nensemble,latS,latN,lonL,lonR,nyear,neof,eofp)

local var,latS,latN,lonL,lonR,nyear,neof,eofp,ensemble_winter,nlat,\
      nlon,deviation,var_winter,area_lat,wsea_variable,x,eof,x_winter,\
      xx_winter,xm_,nra,nca,a,u,v,s,mlat,mlon,eof_1,dev_eof,filter_vector,\
      filter_re,filter_r,v_var1,vv_var1,member_ts,y_ff,msn_original_ts,\
      msn_ts,re_ensemble_winter,pattern,pattern_re,msn_pattern,explained_variance,\
      var1,nensemble
            

begin
    var1 = var
    latS = latS
    latN = latN
    lonL = lonL
    lonR = lonR
    nyear = nyear
    neof = neof
    eofp = eofp
    nensemble = nensemble
    optEOF = True
    optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
    optETS = False

;   printVarSummary(var1)
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
   deviation&time=ispan(0,nensemble*nyear-1,1)
   deviation&latitude=var1&latitude
   deviation&longitude=var1&longitude

   copy_VarCoords(deviation(0,:,:), ensemble_winter(0,:,:))
   ensemble_winter!0="time"
   ensemble_winter&time=ispan(0,nyear-1,1)
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
member_ts&nensemble=ispan(0,nensemble-1,1)
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

;  print(explained_variance(0:(eofp-1)))
  ;print(s)
;;=================================================================
; Statistical significance of MSN EOF mode
; =================================================================


y_m=msn_original_ts
f=(nensemble*dim_variance_n(y_m, 1))/dim_avg_n((dim_variance_n(member_ts, 1)),1)
;42.4
;print("f test values "+f(0:eofp-1))



;==========================================================
;correct the pattern phase to the predictors (external forcing indcies)
;==========================================================
t2m_eof=addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m_2010.nc","r")
tp_pc=addfile("/disk1/fhd/winter_forecast/data/eof_sic_djf_2010.nc","r")
sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/eof_sd_djf_2010.nc","r")
e=addfile("/disk1/fhd/winter_forecast/data/eof_sst_djf_2010.nc","r")

nino=e->eof_ts(0,1:nyear)
pc1=t2m_eof->eof_ts(0,1:nyear)
sd_tp=tp_pc->eof_ts(0,1:nyear)
sd_ea=sd_ea_pc->eof_ts(1:nyear)


cor1=escorc(pc1,msn_ts(0,:))
cor2=escorc(nino,msn_ts(1,:))
cor3=escorc(sd_ea,msn_ts(2,:))
cor4=escorc(sd_tp,msn_ts(3,:))

	if( cor1.lt.0 ) then
		msn_pattern(0,:,:)=msn_pattern(0,:,:)*-1
		msn_ts(0,:)=msn_ts(0,:)*-1
	end if

	if( cor2.lt.0 ) then
		msn_pattern(1,:,:)=msn_pattern(1,:,:)*-1
		msn_ts(1,:)=msn_ts(1,:)*-1
	end if

	if( cor3.lt.0 ) then
		msn_pattern(2,:,:)=msn_pattern(2,:,:)*-1
		msn_ts(2,:)=msn_ts(2,:)*-1
	end if

	if( cor4.lt.0 ) then
		msn_pattern(3,:,:)=msn_pattern(3,:,:)*-1
		msn_ts(3,:)=msn_ts(3,:)*-1
	end if




  out=msn_pattern(0:(eofp-1),:,:)
  out@time_series=msn_ts(0:eofp-1,:)
  out@explained_variance=explained_variance(0:(eofp-1))
  out@f_test = f(0:eofp-1)


  return (out)

end

