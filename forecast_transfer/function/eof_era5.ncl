;===========================================================
; Calculate EOF
; 
;
;*Input data:
;   var   : variable
;   latS,latN,lonL,lonR : area    ; the unit should be latitude&longitude
;   nyear  :the years for  EOF
;   neof   : the number of EOF
;*Output data:
;    out:   EOF 
;    out@time_series : time series
;    out@explained_variance : explained_variance

;*History:
;   2020-04-29: First written by Hongdou Fan of IAP, CAS.
;===========================================================

undef("eof_func")
function eof_func(var,latS,latN,lonL,lonR,nyear,neof)

local var,latS,latN,lonL,lonR,nyear,neof,eofp,ensemble_winter,nlat,\
      nlon,deviation,var_winter,area_lat,wsea_variable,x,eof,x_winter,\
      var1
            

begin
    var1 = var
    latS = latS
    latN = latN
    lonL = lonL
    lonR = lonR
    nyear = nyear
    nof = neof
    optEOF = True
    optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
    optETS = False

    sea_variable =var1(:,{latS:latN},{lonL:lonR})

;;=================================================================
; =================================================================
; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
; =================================================================
rad    = 4.*atan(1.)/180.
clat   = sea_variable&g0_lat_1
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
x     = wsea_variable({g0_lat_1|:},{g0_lon_2|:},initial_time0_hours|:)
eof      = eofunc_Wrap(x, neof, optEOF)
eof_ts   = eofunc_ts_Wrap (x, eof, optETS)


;printVarSummary( eof )                         ; examine EOF variables
;printVarSummary( eof_ts )

; =================================================================
; Normalize time series: Sum spatial weights over the area of used
; =================================================================
dimx  = dimsizes( x )
mln    = dimx(1)
sumWgt = mln*sum(clat)
eof_ts = eof_ts/sumWgt
eof_ts = dim_standardize_Wrap(eof_ts,0)


  out=eof
  out@pc=eof_ts
;  out@explained_variance=eof@pcvar


  return (out)

end

