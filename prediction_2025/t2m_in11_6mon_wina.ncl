
; initial time is november, prediction time is the next december,jan,feb,mar,apr,may

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================

   var     = "t2m"
   varname = "2T_GDS0_SFC"                                                          ; create a plot [?]
;   diri = "/disk4/mssfs/hindcast/sys51/10/monthly/surface/"
;   fill = systemfunc("cd "+diri+" ; ls t2m.*")
;   nfill= dimsizes(fill)
   output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
;   outName = var+"_in11_6mon_wina.nc"                       ; set plot name 
   outName = var+"_in11_6mon_wina_sys51.nc"                       ; set plot name 
   tstart=""
   tend=""
   startyear=1991
   endyear=2020
   nyear= 30
   latitude="g0_lat_2"    ;lat name
   longitude="g0_lon_3"   ;lon name
   levelname   = "lv_ISBL2"      
   level  = " "
   nensemble = 25
   nlatitude= 180
   nlongitude=360


; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
ynumber=ispan(1991,2016,1)
all_files = "/disk4/mssfs/hindcast/ecmwf/sys51/11/monthly/surface/t2m." + ynumber + ".grib"
f = addfiles (all_files, "r")
;---Read "pottmp" in "join" mode and print a summary of the variable
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
   x      = new((/nyear,nensemble,3,nlatitude,nlongitude/),"float")
   x(0:25,:,:,:,:)=indat(:,:,1:3,:,:)
    

ynumber1=ispan(2017,2020,1)
all_files1 = "/disk4/mssfs/forecast/ecmwf/sys51/10/monthly/surface/t2m." + ynumber1 + ".grib"
f1 = addfiles (all_files1, "r")
;---Read "pottmp" in "join" mode and print a summary of the variable
; Read variable(s) multiple data file. Here from CLM 
;===========================================================================
;---Read "pottmp" in "join" mode 
   ListSetType (f1, "join")

   indat1 = f1[:]->$varname$
   x(26:nyear-1,:,:,:,:)=indat1(:,0:24,2:4,:,:)
     
   if (numsize.eq.5) then  
      winter_anom=new((/nyear,nensemble,nlatitude,nlongitude/),"float")     
      winter_mean=dim_avg_n(x,2)
      winter_cli=dim_avg_n(winter_mean,0)
      do i=0,nyear-1
         winter_anom(i,:,:,:)=winter_mean(i,:,:,:)-winter_cli
      end do
      winter_anom!2="latitude"
      winter_anom!3="longitude"
      
   end if
 
   
   
   winter_anom!0="nyear"
   winter_anom!1="nensemble"
   
   winter_anom&nyear=ispan(startyear,endyear,1)
   winter_anom&nensemble=ispan(0,nensemble-1,1)
   winter_anom&latitude=lat
   winter_anom&longitude=lon
   printVarSummary(winter_anom)
          
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
 
cli=dim_avg_n(winter_cli,0)
copy_VarCoords(winter_anom(0,0,:,:),cli)
printVarSummary(cli)
system("rm -f $output$+$outName$.nc")
fout=addfile(output+outName, "c")
fout->winter_anom=winter_anom
fout->winter_cli=cli


end



     
