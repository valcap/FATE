program glf_mnh_ar

use mod_scienceperso

implicit none

INTEGER,PARAMETER                    :: NbMinute=1080 ! 18h=1080minutes
REAL,PARAMETER                       :: NOVAL=0.
CHARACTER(180),ALLOCATABLE,DIMENSION(:)   :: CFILE_DATE
CHARACTER(8),ALLOCATABLE,DIMENSION(:)     :: DATE
CHARACTER(120)                       :: PUBEL,PGPLOT1,PGPLOT2,CFILE_LIST_NIGHTS
CHARACTER(3)                         :: GG
CHARACTER(2)                         :: HH
INTEGER                              :: NbNights,IDELTA,NbPix,K,J,I,IERR,NbLines_TOT,NbLines_TOT_Pix,ICOUNT
INTEGER                              :: NbFit,INC_GLF_MOD_AFT,INC_GLF_MOD_BEF,NB_UNITY_X,NB_UNITY_Y
INTEGER                              :: STARTMINUTE,ENDMINUTE
REAL                                 :: MAXVAL_GLF_OBS_1D,xmin,xmax,xhmin,xhmax
REAL                                 :: BIAS_GLF_MOD_BEF,RMSE_GLF_MOD_BEF,SIGMA_GLF_MOD_BEF
REAL                                 :: BIAS_GLF_MOD_AFT,RMSE_GLF_MOD_AFT,SIGMA_GLF_MOD_AFT
REAL                                 :: B_MOD_AFT,SIGB_MOD_AFT,CHI2_MOD_AFT,Q_MOD_AFT
REAL                                 :: B_MOD_BEF,SIGB_MOD_BEF,CHI2_MOD_BEF,Q_MOD_BEF
REAL                                 :: ACC,MAXGLF,XMED_GLF,X33_GLF,X66_GLF
REAL                                 :: XMED_MOD_BEF,X33_MOD_BEF,X66_MOD_BEF
REAL                                 :: XMED_MOD_AFT,X33_MOD_AFT,X66_MOD_AFT,PC,EBD
CHARACTER(6)                         :: B_MOD_AFTc,B_MOD_BEFc,SIGB_MOD_AFTc,SIGB_MOD_BEFc
CHARACTER(6)                         :: BIAS_MOD_BEFc,BIAS_MOD_AFTc
CHARACTER(6)                         :: RMSE_MOD_BEFc,SIGMA_MOD_BEFc,RMSE_MOD_AFTc,SIGMA_MOD_AFTc
CHARACTER(180)                       :: ROOT
CHARACTER(50)                        :: START,STARTIN,TAIL
INTEGER,ALLOCATABLE,DIMENSION(:)          :: NbLines
INTEGER,DIMENSION(:,:),ALLOCATABLE :: SECONDS,MINUTE,MINUTE_DEF
INTEGER,DIMENSION(:,:),ALLOCATABLE :: INC_GLF_OBS_PIX,INC_GLF_MOD_BEF_PIX,INC_GLF_MOD_AFT_PIX
REAL,DIMENSION(:,:),ALLOCATABLE    :: GLF_OBS,GLF_MOD_BEF,GLF_MOD_AFT
REAL,DIMENSION(:,:),ALLOCATABLE    :: GLF_OBS_DEF,GLF_MOD_BEF_DEF,GLF_MOD_AFT_DEF
REAL,DIMENSION(:,:),ALLOCATABLE    :: GLF_OBS_PIX,GLF_MOD_BEF_PIX,GLF_MOD_AFT_PIX
REAL,DIMENSION(:,:),ALLOCATABLE    :: SD_GLF_OBS_PIX,SD_GLF_MOD_BEF_PIX,SD_GLF_MOD_AFT_PIX
REAL,DIMENSION(:),ALLOCATABLE      :: GLF_OBS_1D,GLF_MOD_BEF_1D,GLF_MOD_AFT_1D,UNITY
REAL,DIMENSION(:),ALLOCATABLE      :: GLF_OBS_1D_LIM,GLF_MOD_BEF_1D_LIM,GLF_MOD_AFT_1D_LIM
REAL,DIMENSION(:),ALLOCATABLE      :: GLF_OBS_1D_FIT,GLF_MOD_BEF_1D_FIT,GLF_MOD_AFT_1D_FIT
REAL,DIMENSION(:),ALLOCATABLE      :: CDX_GLF,CDY_GLF,CDX_MOD_BEF,CDY_MOD_BEF,CDX_MOD_AFT,CDY_MOD_AFT
REAL,DIMENSION(3,3)                :: TAB_HR
REAL,DIMENSION(3)                  :: POD

!***************************************************************
INTERFACE
        SUBROUTINE FIT(Xi,Yi,ai,bi,sigai,sigbi,chi2i,qi,sigi)
        REAL, DIMENSION(:), INTENT(IN) :: xi,yi
        REAL, INTENT(OUT) :: ai,bi,sigai,sigbi,chi2i,qi
        REAL, DIMENSION(:), OPTIONAL, INTENT(IN) :: sigi
        END SUBROUTINE

        SUBROUTINE FIT_ORIG(Xi,Yi,bi,sigbi,chi2i,qi,sigi)
        REAL, DIMENSION(:), INTENT(IN) :: xi,yi
        REAL, INTENT(OUT) :: bi,sigbi,chi2i,qi
        REAL, DIMENSION(:), OPTIONAL, INTENT(IN) :: sigi
        END SUBROUTINE
        
END INTERFACE

!***************************************************************

READ(5,*) GG
PRINT*, 'GG=',GG
READ(5,*) HH
PRINT*, 'HH=',HH
READ(5,*) IDELTA
PRINT*, 'IDELTA=',IDELTA
NbPix=NbMinute/IDELTA
PRINT*,'NbPix=',NbPix
READ(5,*) NbNights
PRINT*, 'NbNights=',NbNights
READ(5,*) STARTMINUTE
STARTMINUTE=STARTMINUTE*60
PRINT*, 'STARTMINUTE=',STARTMINUTE
READ(5,*) ENDMINUTE
ENDMINUTE=ENDMINUTE*60
PRINT*, 'ENDMINUTE=',ENDMINUTE
READ(5,*) MAXGLF
PRINT*, 'MAXGLF=',MAXGLF
READ(5,*) ACC
PRINT*, 'ACC=', ACC
READ(5,*) ROOT
PRINT*, 'ROOT=',TRIM(ROOT)
READ(5,*) TAIL
PRINT*, 'TAIL=',TRIM(TAIL)
READ(5,*) STARTIN
PRINT*, 'STARTIN=',TRIM(STARTIN)
READ (5,*) CFILE_LIST_NIGHTS
PRINT*, 'CFILE_LIST_NIGHTS=',CFILE_LIST_NIGHTS
READ (5,*)PGPLOT1
PRINT*, PGPLOT1
READ (5,*)PGPLOT2
PRINT*, PGPLOT2

ALLOCATE(CFILE_DATE(NbNights))
ALLOCATE(DATE(NbNights))
ALLOCATE(NbLines(NbNights))

START=TRIM(STARTIN)//TRIM(HH)//"_"
PRINT*,TRIM(START)


DO I=1,NbNights
OPEN(UNIT=90,FILE=CFILE_LIST_NIGHTS,FORM='FORMATTED',IOSTAT=IERR,STATUS='OLD',ACCESS='SEQUENTIAL')
READ(90,*) DATE(I)
ENDDO
CLOSE(90)

DO I=1,NbNights
CFILE_DATE(I)=TRIM(ROOT)//TRIM(START)//TRIM(DATE(I))//TRIM(TAIL)
!PRINT*,I,CFILE_DATE(I)
ENDDO

NbLines(:)=0
DO I=1,NbNights
  OPEN(UNIT=90,FILE=CFILE_DATE(I),FORM='FORMATTED',IOSTAT=IERR,STATUS='OLD',ACCESS='SEQUENTIAL')
  DO WHILE (IERR==0)
  READ(90,*, IOSTAT=IERR)
   IF (IERR==0) THEN
   NbLines(I)=NbLines(I)+1
   ENDIF
  ENDDO
  CLOSE(90)
  NbLines(I)=NbLines(I)-2
!PRINT*,'Number of ', I,'is equal to:',  NbLines(I)
ENDDO

NbLines_TOT=MAXVAL(NbLines)
PRINT*,'NbLines_TOT=',NbLines_TOT

ALLOCATE(SECONDS(NbNights,NbLines_TOT))
ALLOCATE(MINUTE(NbNights,NbLines_TOT))
ALLOCATE(GLF_OBS(NbNights,NbLines_TOT))
ALLOCATE(GLF_MOD_BEF(NbNights,NbLines_TOT))
ALLOCATE(GLF_MOD_AFT(NbNights,NbLines_TOT))
SECONDS(:,:)=int(NOVAL)
MINUTE(:,:)=int(NOVAL)
GLF_OBS(:,:)=NOVAL
GLF_MOD_BEF(:,:)=NOVAL
GLF_MOD_AFT(:,:)=NOVAL

DO I=1,NbNights
OPEN(UNIT=90,FILE=CFILE_DATE(I),FORM='FORMATTED',STATUS='OLD',ACCESS='SEQUENTIAL')
  READ(90,*) PUBEL
  READ(90,*) PUBEL
    DO J=1,NbLines(I)
    READ(90,*) SECONDS(I,J),GLF_OBS(I,J),GLF_MOD_BEF(I,J),GLF_MOD_AFT(I,J)

    if((SECONDS(I,J).ne.INT(NOVAL)).AND.(GLF_OBS(I,J).ne.9999.))then
    MINUTE(I,J)=SECONDS(I,J)/60
    GLF_OBS(I,J)=GLF_OBS(I,J)*0.01
    GLF_MOD_BEF(I,J)=GLF_MOD_BEF(I,J)*0.01
    GLF_MOD_AFT(I,J)=GLF_MOD_AFT(I,J)*0.01
    else
    MINUTE(I,J)=int(NOVAL)
    GLF_OBS(I,J)=NOVAL
    GLF_MOD_BEF(I,J)=NOVAL
    GLF_MOD_AFT(I,J)=NOVAL
    end if

    ENDDO
CLOSE(90)
ENDDO

ALLOCATE(MINUTE_DEF(NbNights,NbMinute))
ALLOCATE(GLF_OBS_DEF(NbNights,NbMinute))
ALLOCATE(GLF_MOD_BEF_DEF(NbNights,NbMinute))
ALLOCATE(GLF_MOD_AFT_DEF(NbNights,NbMinute))
MINUTE_DEF(:,:)=int(NOVAL)
GLF_OBS_DEF(:,:)=NOVAL
GLF_MOD_BEF_DEF(:,:)=NOVAL
GLF_MOD_AFT_DEF(:,:)=NOVAL

DO I=1,NbNights
DO J=1,NbLines(I)
IF((MINUTE(I,J).NE.0).AND.(GLF_OBS(I,J).NE.9999.))THEN
MINUTE_DEF(I,MINUTE(I,J))=MINUTE(I,J)
GLF_OBS_DEF(I,MINUTE(I,J))=GLF_OBS(I,J)
GLF_MOD_BEF_DEF(I,MINUTE(I,J))=GLF_MOD_BEF(I,J)
GLF_MOD_AFT_DEF(I,MINUTE(I,J))=GLF_MOD_AFT(I,J)
ENDIF
ENDDO
ENDDO

PRINT*,'MINUTE_DEF(1,1)=',MINUTE_DEF(1,1),'MINUTE_DEF(1,869)=',MINUTE_DEF(1,869)


ALLOCATE(GLF_OBS_PIX(NbNights,NbPix))
GLF_OBS_PIX(:,:)=NOVAL
ALLOCATE(SD_GLF_OBS_PIX(NbNights,NbPix))
SD_GLF_OBS_PIX(:,:)=NOVAL
ALLOCATE(INC_GLF_OBS_PIX(NbNights,NbPix))
INC_GLF_OBS_PIX(:,:)=NOVAL
ALLOCATE(GLF_MOD_BEF_PIX(NbNights,NbPix))
GLF_MOD_BEF_PIX(:,:)=NOVAL
ALLOCATE(SD_GLF_MOD_BEF_PIX(NbNights,NbPix))
SD_GLF_MOD_BEF_PIX(:,:)=NOVAL
ALLOCATE(INC_GLF_MOD_BEF_PIX(NbNights,NbPix))
INC_GLF_MOD_BEF_PIX(:,:)=NOVAL
ALLOCATE(GLF_MOD_AFT_PIX(NbNights,NbPix))
GLF_MOD_AFT_PIX(:,:)=NOVAL
ALLOCATE(SD_GLF_MOD_AFT_PIX(NbNights,NbPix))
SD_GLF_MOD_AFT_PIX(:,:)=NOVAL
ALLOCATE(INC_GLF_MOD_AFT_PIX(NbNights,NbPix))
INC_GLF_MOD_AFT_PIX(:,:)=NOVAL

!
DO I=1,NbNights
CALL RESAMPLING_AVERAGE(GLF_OBS_DEF(I,:),NbMinute,IDELTA,GLF_OBS_PIX(I,:),NbPix,SD_GLF_OBS_PIX(I,:),NOVAL)
CALL RESAMPLING_AVERAGE(GLF_MOD_BEF_DEF(I,:),NbMinute,IDELTA,GLF_MOD_BEF_PIX(I,:),NbPix,SD_GLF_MOD_BEF_PIX(I,:),NOVAL)
CALL RESAMPLING_AVERAGE(GLF_MOD_AFT_DEF(I,:),NbMinute,IDELTA,GLF_MOD_AFT_PIX(I,:),NbPix,SD_GLF_MOD_AFT_PIX(I,:),NOVAL)
ENDDO

PRINT*,'End of OBS data treatement'
!
NbLines_TOT_Pix=NbNights*NbPix
PRINT*,'NbLines_TOT_Pix=',NbLines_TOT_Pix

ALLOCATE(GLF_OBS_1D(NbLines_TOT_Pix))
ALLOCATE(GLF_MOD_BEF_1D(NbLines_TOT_Pix))
ALLOCATE(GLF_MOD_AFT_1D(NbLines_TOT_Pix))
GLF_OBS_1D(:)=NOVAL
GLF_MOD_BEF_1D(:)=NOVAL
GLF_MOD_AFT_1D(:)=NOVAL
!
K=0
DO I=1,NbNights
DO J=1,NbPix
 K=(I-1)*NbPix+J
 GLF_OBS_1D(K)=GLF_OBS_PIX(I,J)
 GLF_MOD_BEF_1D(K)=GLF_MOD_BEF_PIX(I,J)
 GLF_MOD_AFT_1D(K)=GLF_MOD_AFT_PIX(I,J)
! PRINT*,I,J,K,GLF_OBS_1D(K),GLF_MOD_BEF_1D(K),GLF_MOD_AFT_1D(K)
ENDDO
ENDDO
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! FILTRAGGIO per il calcolo di bias, RMSE,sigma
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! Usare MAXVAL_GLF_DIMM_1D quando vogliamo prendere in considerazione tutti i valori del seeing
! Usare 1.5 quando vogliamo filtrare
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
if (MAXGLF .eq. 999.) then
  MAXVAL_GLF_OBS_1D=MAXVAL(GLF_OBS_1D)
else
  MAXVAL_GLF_OBS_1D=MAXGLF
end if
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

PRINT*,'MAXVAL_GLF_OBS_1D=',MAXVAL_GLF_OBS_1D

ALLOCATE(GLF_OBS_1D_LIM(NbLines_TOT_Pix))
ALLOCATE(GLF_MOD_BEF_1D_LIM(NbLines_TOT_Pix))
ALLOCATE(GLF_MOD_AFT_1D_LIM(NbLines_TOT_Pix))
GLF_OBS_1D_LIM(:)=NOVAL
GLF_MOD_BEF_1D_LIM(:)=NOVAL
GLF_MOD_AFT_1D_LIM(:)=NOVAL
!
! we had introduced MAXVAL_GLF_OBS_1D to have the possibility to take seeing < 1.5 arcsec
! per GLF non serve ma e' rimnasto per omogenieta' con programmi per altri parametri
!
DO I=1,NbLines_TOT_Pix
IF(GLF_OBS_1D(I).LE.MAXVAL_GLF_OBS_1D)THEN
GLF_OBS_1D_LIM(I)=GLF_OBS_1D(I)
GLF_MOD_BEF_1D_LIM(I)=GLF_MOD_BEF_1D(I)
GLF_MOD_AFT_1D_LIM(I)=GLF_MOD_AFT_1D(I)
!print*,GLF_OBS_1D_LIM(I),GLF_MOD_BEF_1D_LIM(I),GLF_MOD_AFT_1D_LIM(I)
ENDIF
ENDDO

open(78,file='test.dat',status='unknown',form='formatted')
DO I=1,NbLines_TOT_Pix
IF((GLF_OBS_1D_LIM(I).NE.0.).AND.(GLF_MOD_BEF_1D_LIM(I).NE.0.).AND.(GLF_MOD_AFT_1D_LIM(I).NE.0.))THEN
WRITE(78,*)I,GLF_OBS_1D_LIM(I),GLF_MOD_BEF_1D_LIM(I),GLF_MOD_AFT_1D_LIM(I)
ENDIF
ENDDO
close(78)

!
! Calculation of BIAS and RMSE
!
CALL BIAS_RMSE_SIGMA(GLF_OBS_1D_LIM,GLF_MOD_BEF_1D_LIM,NbLines_TOT_Pix,BIAS_GLF_MOD_BEF,RMSE_GLF_MOD_BEF, &
         SIGMA_GLF_MOD_BEF,INC_GLF_MOD_BEF,NOVAL)
PRINT*,'BIAS_GLF_MOD_BEF=',BIAS_GLF_MOD_BEF
PRINT*,'RMSE_GLF_MOD_BEF=',RMSE_GLF_MOD_BEF
PRINT*,'SIGMA_GLF_MOD_BEF=',SIGMA_GLF_MOD_BEF
PRINT*,'INC_GLF_MOD_BEF=',INC_GLF_MOD_BEF
PRINT*,'NbLines_TOT=',NbLines_TOT_Pix
WRITE(BIAS_MOD_BEFc,'(f5.2)')BIAS_GLF_MOD_BEF
WRITE(RMSE_MOD_BEFc,'(f5.2)')RMSE_GLF_MOD_BEF
WRITE(SIGMA_MOD_BEFc,'(f5.2)')SIGMA_GLF_MOD_BEF
!
CALL BIAS_RMSE_SIGMA(GLF_OBS_1D_LIM,GLF_MOD_AFT_1D_LIM,NbLines_TOT_Pix,BIAS_GLF_MOD_AFT,RMSE_GLF_MOD_AFT, &
         SIGMA_GLF_MOD_AFT,INC_GLF_MOD_AFT,NOVAL)
PRINT*,'BIAS_GLF_MOD_AFT=',BIAS_GLF_MOD_AFT
PRINT*,'RMSE_GLF_MOD_AFT=',RMSE_GLF_MOD_AFT
PRINT*,'SIGMA_GLF_MOD_AFT=',SIGMA_GLF_MOD_AFT
PRINT*,'INC_GLF_MOD_AFT=',INC_GLF_MOD_AFT
PRINT*,'NbLines_TOT=',NbLines_TOT_Pix
WRITE(BIAS_MOD_AFTc,'(f5.2)')BIAS_GLF_MOD_AFT
WRITE(RMSE_MOD_AFTc,'(f5.2)')RMSE_GLF_MOD_AFT
WRITE(SIGMA_MOD_AFTc,'(f5.2)')SIGMA_GLF_MOD_AFT
!

ICOUNT=0
DO I=1,NbLines_TOT_Pix
IF( (GLF_OBS_1D_LIM(I).NE.NOVAL).AND.(GLF_MOD_BEF_1D_LIM(I).NE.NOVAL).AND.(GLF_MOD_AFT_1D_LIM(I).NE.NOVAL) )THEN
ICOUNT=ICOUNT+1
ENDIF
ENDDO
NbFit=ICOUNT
PRINT*,'NbFit=',NbFit,'NbLines_TOT=',NbLines_TOT,'NbPix=',NbPix
!
ALLOCATE(GLF_OBS_1D_FIT(NbFit))
GLF_OBS_1D_FIT(:)=NOVAL
ALLOCATE(GLF_MOD_BEF_1D_FIT(NbFit))
GLF_MOD_BEF_1D_FIT(:)=NOVAL
ALLOCATE(GLF_MOD_AFT_1D_FIT(NbFit))
GLF_MOD_AFT_1D_FIT(:)=NOVAL
!
K=0
PRINT*,'K=',K
DO I=1,NbLines_TOT_Pix
IF( (GLF_OBS_1D_LIM(I).NE.NOVAL).AND.(GLF_MOD_BEF_1D_LIM(I).NE.NOVAL).AND.(GLF_MOD_AFT_1D_LIM(I).NE.NOVAL) )THEN
K=K+1
GLF_OBS_1D_FIT(K)=GLF_OBS_1D_LIM(I)
GLF_MOD_BEF_1D_FIT(K)=GLF_MOD_BEF_1D_LIM(I)
GLF_MOD_AFT_1D_FIT(K)=GLF_MOD_AFT_1D_LIM(I)
!PRINT*,'I=',I,'K=',K,GLF_OBS_1D_FIT(K),GLF_MOD_BEF_1D_FIT(K),GLF_MOD_AFT_1D_FIT(K)
ENDIF
ENDDO
!
!!!!!!!!!!!!!!!!!
! WRITE output file for pyton
!!!!!!!!!!!!!!!!!

OPEN(unit=90,file='out_scatter_for_python_bef.dat',form='formatted',status='new',access='append')
DO I=1,NbFit
WRITE(90,*) GLF_OBS_1D_FIT(I),GLF_MOD_BEF_1D_FIT(I)
ENDDO
CLOSE(90)

OPEN(unit=91,file='out_scatter_for_python_aft.dat',form='formatted',status='new',access='append')
DO I=1,NbFit
WRITE(91,*) GLF_OBS_1D_FIT(I),GLF_MOD_AFT_1D_FIT(I)
ENDDO
CLOSE(91)
!
!
! LINEAR REGRESSION
!
PRINT*,'#### FIT BEF ####'
CALL FIT_ORIG(GLF_OBS_1D_FIT,GLF_MOD_BEF_1D_FIT,B_MOD_BEF,SIGB_MOD_BEF,CHI2_MOD_BEF,Q_MOD_BEF)
PRINT*,'B_TOT(slope)=',B_MOD_BEF
WRITE(B_MOD_BEFc,'(f4.2)')B_MOD_BEF
WRITE(SIGB_MOD_BEFc,'(f4.2)')SIGB_MOD_BEF

PRINT*,'#### FIT AFT #####'
CALL FIT_ORIG(GLF_OBS_1D_FIT,GLF_MOD_AFT_1D_FIT,B_MOD_AFT,SIGB_MOD_AFT,CHI2_MOD_AFT,Q_MOD_AFT)
PRINT*,'B_TOT(slope)=',B_MOD_AFT
WRITE(B_MOD_AFTc,'(f4.2)')B_MOD_AFT
WRITE(SIGB_MOD_AFTc,'(f4.2)')SIGB_MOD_AFT
!

ALLOCATE(CDX_GLF(NbFit))
ALLOCATE(CDY_GLF(NbFit))
CDX_GLF=NOVAL
CDY_GLF=NOVAL

PRINT*,'***************'
CALL CUMDIST_TERTILES(NbFit,GLF_OBS_1D_FIT,CDX_GLF,CDY_GLF,XMED_GLF,X33_GLF,X66_GLF)
PRINT*,'XMED_GLF=',XMED_GLF
PRINT*,'X33_GLF=',X33_GLF
PRINT*,'X66_GLF=',X66_GLF
PRINT*,'***************'
!
ALLOCATE(CDX_MOD_BEF(NbFit))
ALLOCATE(CDY_MOD_BEF(NbFit))
CDX_MOD_BEF=NOVAL
CDY_MOD_BEF=NOVAL
PRINT*,'***************'
CALL CUMDIST_TERTILES(NbFit,GLF_MOD_BEF_1D_FIT,CDX_MOD_BEF,CDY_MOD_BEF,XMED_MOD_BEF,X33_MOD_BEF,X66_MOD_BEF)
PRINT*,'XMED_MOD_BEF=',XMED_MOD_BEF
PRINT*,'***************'
!
PRINT*,'##########################################'
PRINT*,'######## HIT_RATE for BEF ###########'
PRINT*,'##########################################'
!
! Calcultion of hit-rate using as extreme the first and thrid tertile of the GLF
! Attention: the hit_rate is calculated only in the case without filter i.e. MAXVALGLF=999.
!
POD=NOVAL
TAB_HR=NOVAL
!CALL HIT_RATE(GLF_OBS_1D_FIT,GLF_MOD_BEF_1D_FIT,NbFit,X33_GLF,X66_GLF,NOVAL,TAB_HR,POD,PC,EBD,.false.)
CALL HIT_RATE(GLF_OBS_1D_FIT,GLF_MOD_BEF_1D_FIT,NbFit,0.50,0.70,NOVAL,TAB_HR,POD,PC,EBD,.false.)
!
PRINT*,'**************************************************'
PRINT*,'****** HIT_RATE for BEF WITH RMSE=SD_instr *******'
PRINT*,'**************************************************'
!
!CALL HIT_RATE_MOD(GLF_OBS_1D_FIT,GLF_MOD_BEF_1D_FIT,NbFit,X33_GLF,X66_GLF,NOVAL,TAB_HR,POD,PC,EBD,ACC,.false.)
CALL HIT_RATE_MOD(GLF_OBS_1D_FIT,GLF_MOD_BEF_1D_FIT,NbFit,0.50,0.70,NOVAL,TAB_HR,POD,PC,EBD,ACC,.false.)
!
ALLOCATE(CDX_MOD_AFT(NbFit))
ALLOCATE(CDY_MOD_AFT(NbFit))
CDX_MOD_AFT=NOVAL
CDY_MOD_AFT=NOVAL
PRINT*,'***************'
CALL CUMDIST_TERTILES(NbFit,GLF_MOD_AFT_1D_FIT,CDX_MOD_AFT,CDY_MOD_AFT,XMED_MOD_AFT,X33_MOD_AFT,X66_MOD_AFT)
PRINT*,'XMED_MOD_AFT=',XMED_MOD_AFT
PRINT*,'***************'
!
PRINT*,'##########################################'
PRINT*,'############ HIT_RATE for AFT #############'
PRINT*,'##########################################'
!
! Calcultion of hit-rate using as extreme the first and thrid tertile of the GLF
!
POD(:)=NOVAL
TAB_HR=NOVAL
!CALL HIT_RATE(GLF_OBS_1D_FIT,GLF_MOD_AFT_1D_FIT,NbFit,X33_GLF,X66_GLF,NOVAL,TAB_HR,POD,PC,EBD,.false.)
CALL HIT_RATE(GLF_OBS_1D_FIT,GLF_MOD_AFT_1D_FIT,NbFit,0.50,0.70,NOVAL,TAB_HR,POD,PC,EBD,.false.)

!
PRINT*,'**************************************************'
PRINT*,'****** HIT_RATE for AFT WITH RMSE=SD_instr *******'
PRINT*,'**************************************************'
!
CALL HIT_RATE_MOD(GLF_OBS_1D_FIT,GLF_MOD_AFT_1D_FIT,NbFit,X33_GLF,X66_GLF,NOVAL,TAB_HR,POD,PC,EBD,ACC,.false.)

!
!  Graphics
!

xmin=0.
xmax=1.
xhmin=0.
xhmax=1.
NB_UNITY_X=INT(xmax)*200
NB_UNITY_Y=INT(xhmax)*200

ALLOCATE(UNITY(NB_UNITY_X))
UNITY(:)=0

DO I=1,NB_UNITY_X
UNITY(I)=I*0.01
ENDDO
!
CALL PGBEGIN(0,PGPLOT1,2,2)
CALL PGSCH(1.8)
CALL PGSLW(3)  ! paper
CALL PGENV(xmin,xmax,xhmin,xhmax,1,0)
CALL PGLABEL('OBS: GLF','PERSISTENCE: GLF','PERSISTENCE')
DO I=1,NbNights
 DO J=1,NbPix
   IF( (GLF_OBS_PIX(I,J).NE.NOVAL).AND.(GLF_MOD_BEF_PIX(I,J).NE.NOVAL)&
       .AND.(GLF_OBS_PIX(I,J).LE.MAXVAL_GLF_OBS_1D))THEN
   CALL PGSLW(4)
   CALL PGPT(1,GLF_OBS_PIX(I,J),GLF_MOD_BEF_PIX(I,J),-1)
   ENDIF
 ENDDO
ENDDO
   CALL PGSCH(1.5)
   CALL PGSLW(2)
   CALL PGSLS(2)
   CALL PGLINE(NB_UNITY_X,UNITY,UNITY)
   CALL PGSLS(1)
   CALL PGSCI(1)
   CALL PGTEXT(xmax*0.05,xhmax*0.2,'BIAS='//BIAS_MOD_BEFc)
   CALL PGTEXT(xmax*0.05,xhmax*0.15,'RMSE='//RMSE_MOD_BEFc)
   CALL PGTEXT(xmax*0.05,xhmax*0.1,'sigma='//SIGMA_MOD_BEFc)
   CALL PGTEXT(xmax*0.70,xhmax*0.12,'y=Bx')
   CALL PGTEXT(xmax*0.70,xhmax*0.07,'B='//B_MOD_BEFc)
   CALL PGSLW(3)
   CALL PGLINE(NB_UNITY_X,UNITY,B_MOD_BEF*UNITY)
   CALL PGSCI(1)
CALL PGEND

CALL PGBEGIN(0,PGPLOT2,2,2)
CALL PGSCH(1.8)
CALL PGSLW(3)  ! paper
CALL PGENV(xmin,xmax,xhmin,xhmax,1,0)
CALL PGLABEL('OBS: GLF','PERSISTENCE: GLF','PERSISTENCE')
DO I=1,NbNights
 DO J=1,NbPix
   IF( (GLF_OBS_PIX(I,J).NE.0).AND.(GLF_MOD_AFT_PIX(I,J).NE.0)&
       .AND.(GLF_OBS_PIX(I,J).LE.MAXVAL_GLF_OBS_1D))THEN
   CALL PGSLW(4)
   CALL PGPT(1,GLF_OBS_PIX(I,J),GLF_MOD_AFT_PIX(I,J),-1)
   ENDIF
 ENDDO
ENDDO
   CALL PGSCH(1.5)
   CALL PGSLW(2)
   CALL PGSLS(2)
   CALL PGLINE(NB_UNITY_X,UNITY,UNITY)
   CALL PGSLS(1)
   CALL PGSCI(1)
   CALL PGTEXT(xmax*0.05,xhmax*0.9,'BIAS='//BIAS_MOD_AFTc)
   CALL PGTEXT(xmax*0.05,xhmax*0.85,'RMSE='//RMSE_MOD_AFTc)
   CALL PGTEXT(xmax*0.05,xhmax*0.8,'sigma='//SIGMA_MOD_AFTc)
   CALL PGTEXT(xmax*0.70,xhmax*0.12,'y=Bx')
!   CALL PGTEXT(xmax*0.50,xhmax*0.07,'B='//B_MOD_AFTc//'+/-'//SIGB_MOD_AFTc)
   CALL PGTEXT(xmax*0.70,xhmax*0.07,'B='//B_MOD_AFTc)
   CALL PGSLW(3)
   CALL PGLINE(NB_UNITY_X,UNITY,B_MOD_AFT*UNITY)
   CALL PGSCI(1)
CALL PGEND



end program
