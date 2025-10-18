
; initial time is november, prediction time is the next december,jan,feb,mar,apr,may

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================

   var     = "sic"
   varname = "CI_GDS0_SFC"                                                          ; create a plot [?]
   diri = "/disk4/mssfs/hindcast/ecmwf/11/monthly/surface/"
   fill = systemfunc("cd "+diri+" ; ls sic.*")
   nfill= dimsizes(fill)
   output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
;   outName = var+"_in11_6mon_wina.nc"                       ; set plot name 
   outName = var+"_in11_cli_2010.nc"                       ; set plot name 
   tstart=""
   tend=""
   startyear=1981
   endyear=2016
   nyear= 36
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
   nensemble = 25
   nlatitude= 181
   nlongitude=360
;latS   =  .
;latN   =  .
;lonL   =  .
;lonR   =  .

;  yrStrt = 1981
;  yrLast = 2016


; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

  
  
   print("nfill="+nfill)
   f    = addfiles(diri+fill,"r") 

   
   
   
;   printVarSummary(f)
   ;===========================================================================
; Read variable(s) multiple data file. Here from CLM 
;===========================================================================
;---Read "pottmp" in "join" mode 
   ListSetType (f, "join") 
   
   lat  = f[0]->$latitude$                ; (lndgrid)); same for all files
   lon  = f[0]->$longitude$               ;              "             "
;   topo = f[0]->lev                      ; 
   indat = f[:]->$varname$
   
   datasizes	= dimsizes(indat)
   numsize 	= dimsizes(datasizes)
   x      = indat(0:29,:,:,:,:)         
      winter_mean=dim_avg_n(x(:,:,1:3,:,:),2)
      winter_cli=dim_avg_n(winter_mean,0)
 
   
   
; ==============================================================
 
cli=dim_avg_n(winter_cli,0)
copy_VarCoords(x(0,0,0,:,:),cli)

system("rm -f $output$+$outName$.nc")
fout=addfile(output+outName, "c")
;fout->winter_anom=winter_anom
fout->winter_cli=cli


end


     
