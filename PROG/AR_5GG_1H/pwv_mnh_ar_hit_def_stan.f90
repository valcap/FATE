program pwv_mnh_ar

use mod_scienceperso

implicit none

INTEGER,PARAMETER                    :: NbMinute=1080 ! 18h=1080minutes
REAL,PARAMETER                       :: NOVAL=0.
CHARACTER(180),ALLOCATABLE,DIMENSION(:)   :: CFILE_DATE
CHARACTER(8),ALLOCATABLE,DIMENSION(:)     :: DATE
CHARACTER(120)                       :: PUBEL,PGPLOT1,PGPLOT2,CFILE_LIST_NIGHTS
CHARACTER(3)                         :: GG
CHARACTER(2)                         :: HH
INTEGER                              :: IDELTA,NbPix,K,J,I,IERR,NbLines_TOT,NbLines_TOT_Pix,ICOUNT
INTEGER                              :: NbFit,INC_PWV_MOD_AFT,INC_PWV_MOD_BEF,NB_UNITY_X,NB_UNITY_Y
INTEGER                              :: NbNights,STARTMINUTE,ENDMINUTE
REAL                                 :: MAXPWV,MAXVAL_PWV_OBS_1D,xmin,xmax,xhmin,xhmax
REAL                                 :: BIAS_PWV_MOD_BEF,RMSE_PWV_MOD_BEF,SIGMA_PWV_MOD_BEF
REAL                                 :: BIAS_PWV_MOD_AFT,RMSE_PWV_MOD_AFT,SIGMA_PWV_MOD_AFT
REAL                                 :: B_MOD_AFT,SIGB_MOD_AFT,CHI2_MOD_AFT,Q_MOD_AFT
REAL                                 :: B_MOD_BEF,SIGB_MOD_BEF,CHI2_MOD_BEF,Q_MOD_BEF
REAL                                 :: XMED_PWV,X33_PWV,X66_PWV
REAL                                 :: XMED_MOD_BEF,X33_MOD_BEF,X66_MOD_BEF
REAL                                 :: XMED_MOD_AFT,X33_MOD_AFT,X66_MOD_AFT,PC,EBD
CHARACTER(6)                         :: B_MOD_AFTc,B_MOD_BEFc,SIGB_MOD_AFTc,SIGB_MOD_BEFc
CHARACTER(6)                         :: BIAS_MOD_BEFc,BIAS_MOD_AFTc
CHARACTER(6)                         :: RMSE_MOD_BEFc,SIGMA_MOD_BEFc,RMSE_MOD_AFTc,SIGMA_MOD_AFTc
CHARACTER(180)                       :: ROOT
CHARACTER(40)                        :: START,TAIL,STARTIN
INTEGER,ALLOCATABLE,DIMENSION(:)          :: NbLines
INTEGER,DIMENSION(:,:),ALLOCATABLE :: SECONDS,MINUTE,MINUTE_DEF
INTEGER,DIMENSION(:,:),ALLOCATABLE :: INC_PWV_OBS_PIX,INC_PWV_MOD_BEF_PIX,INC_PWV_MOD_AFT_PIX
REAL,DIMENSION(:,:),ALLOCATABLE    :: PWV_OBS,PWV_MOD_BEF,PWV_MOD_AFT
REAL,DIMENSION(:,:),ALLOCATABLE    :: PWV_OBS_DEF,PWV_MOD_BEF_DEF,PWV_MOD_AFT_DEF
REAL,DIMENSION(:,:),ALLOCATABLE    :: PWV_OBS_PIX,PWV_MOD_BEF_PIX,PWV_MOD_AFT_PIX
REAL,DIMENSION(:,:),ALLOCATABLE    :: PWV_OBS_PIX_LIM,PWV_MOD_BEF_PIX_LIM,PWV_MOD_AFT_PIX_LIM
REAL,DIMENSION(:,:),ALLOCATABLE    :: SD_PWV_OBS_PIX,SD_PWV_MOD_BEF_PIX,SD_PWV_MOD_AFT_PIX
REAL,DIMENSION(:),ALLOCATABLE      :: PWV_OBS_1D,PWV_MOD_BEF_1D,PWV_MOD_AFT_1D,UNITY
REAL,DIMENSION(:),ALLOCATABLE      :: PWV_OBS_1D_LIM,PWV_MOD_BEF_1D_LIM,PWV_MOD_AFT_1D_LIM
REAL,DIMENSION(:),ALLOCATABLE      :: PWV_OBS_1D_FIT,PWV_MOD_BEF_1D_FIT,PWV_MOD_AFT_1D_FIT
REAL,DIMENSION(:),ALLOCATABLE      :: CDX_PWV,CDY_PWV,CDX_MOD_BEF,CDY_MOD_BEF,CDX_MOD_AFT,CDY_MOD_AFT
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
READ(5,*) MAXPWV
PRINT*, 'MAXPWV=',MAXPWV
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

START=TRIM(STARTIN)//TRIM(HH)//"_"//TRIM(GG)//"_"
PRINT*,TRIM(START)

DO I=1,NbNights
OPEN(UNIT=90,FILE=CFILE_LIST_NIGHTS,FORM='FORMATTED',IOSTAT=IERR,STATUS='OLD',ACCESS='SEQUENTIAL')
READ(90,*) DATE(I)
ENDDO
CLOSE(90)

DO I=1,NbNights
CFILE_DATE(I)=TRIM(ROOT)//TRIM(START)//TRIM(DATE(I))//TRIM(TAIL)
!PRINT*,CFILE_DATE(I)
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
ALLOCATE(PWV_OBS(NbNights,NbLines_TOT))
ALLOCATE(PWV_MOD_BEF(NbNights,NbLines_TOT))
ALLOCATE(PWV_MOD_AFT(NbNights,NbLines_TOT))
SECONDS(:,:)=int(NOVAL)
MINUTE(:,:)=int(NOVAL)
PWV_OBS(:,:)=NOVAL
PWV_MOD_BEF(:,:)=NOVAL
PWV_MOD_AFT(:,:)=NOVAL

DO I=1,NbNights
OPEN(UNIT=90,FILE=CFILE_DATE(I),FORM='FORMATTED',STATUS='OLD',ACCESS='SEQUENTIAL')
  READ(90,*) PUBEL
  READ(90,*) PUBEL
    DO J=1,NbLines(I)
    READ(90,*) SECONDS(I,J),PWV_OBS(I,J),PWV_MOD_BEF(I,J),PWV_MOD_AFT(I,J)
    if((SECONDS(I,J) .ne.INT(NOVAL)).AND.(PWV_OBS(I,J).ne.9999.))then
    MINUTE(I,J)=SECONDS(I,J)/60
    else
    MINUTE(I,J)=int(NOVAL)
    PWV_OBS(I,J)=NOVAL
    PWV_MOD_BEF(I,J)=NOVAL
    PWV_MOD_AFT(I,J)=NOVAL
    end if
    if((SECONDS(I,J) .lt. STARTMINUTE) .or. (SECONDS(I,J) .gt. ENDMINUTE))  then
    PWV_OBS(I,J)=NOVAL
    PWV_MOD_BEF(I,J)=NOVAL
    PWV_MOD_AFT(I,J)=NOVAL
endif
    ENDDO
CLOSE(90)
ENDDO

ALLOCATE(MINUTE_DEF(NbNights,NbMinute))
ALLOCATE(PWV_OBS_DEF(NbNights,NbMinute))
ALLOCATE(PWV_MOD_BEF_DEF(NbNights,NbMinute))
ALLOCATE(PWV_MOD_AFT_DEF(NbNights,NbMinute))
MINUTE_DEF(:,:)=int(NOVAL)
PWV_OBS_DEF(:,:)=NOVAL
PWV_MOD_BEF_DEF(:,:)=NOVAL
PWV_MOD_AFT_DEF(:,:)=NOVAL

DO I=1,NbNights
DO J=1,NbLines(I)
IF(MINUTE(I,J).NE.0)THEN
MINUTE_DEF(I,MINUTE(I,J))=MINUTE(I,J)
PWV_OBS_DEF(I,MINUTE(I,J))=PWV_OBS(I,J)
PWV_MOD_BEF_DEF(I,MINUTE(I,J))=PWV_MOD_BEF(I,J)
PWV_MOD_AFT_DEF(I,MINUTE(I,J))=PWV_MOD_AFT(I,J)
ENDIF
ENDDO
ENDDO

PRINT*,'MINUTE_DEF(1,1)=',MINUTE_DEF(1,1),'MINUTE_DEF(1,869)=',MINUTE_DEF(1,869)


ALLOCATE(PWV_OBS_PIX(NbNights,NbPix))
PWV_OBS_PIX(:,:)=NOVAL
ALLOCATE(SD_PWV_OBS_PIX(NbNights,NbPix))
SD_PWV_OBS_PIX(:,:)=NOVAL
ALLOCATE(INC_PWV_OBS_PIX(NbNights,NbPix))
INC_PWV_OBS_PIX(:,:)=NOVAL
ALLOCATE(PWV_MOD_BEF_PIX(NbNights,NbPix))
PWV_MOD_BEF_PIX(:,:)=NOVAL
ALLOCATE(SD_PWV_MOD_BEF_PIX(NbNights,NbPix))
SD_PWV_MOD_BEF_PIX(:,:)=NOVAL
ALLOCATE(INC_PWV_MOD_BEF_PIX(NbNights,NbPix))
INC_PWV_MOD_BEF_PIX(:,:)=NOVAL
ALLOCATE(PWV_MOD_AFT_PIX(NbNights,NbPix))
PWV_MOD_AFT_PIX(:,:)=NOVAL
ALLOCATE(SD_PWV_MOD_AFT_PIX(NbNights,NbPix))
SD_PWV_MOD_AFT_PIX(:,:)=NOVAL
ALLOCATE(INC_PWV_MOD_AFT_PIX(NbNights,NbPix))
INC_PWV_MOD_AFT_PIX(:,:)=NOVAL

!
DO I=1,NbNights
CALL RESAMPLING_AVERAGE(PWV_OBS_DEF(I,:),NbMinute,IDELTA,PWV_OBS_PIX(I,:),NbPix,SD_PWV_OBS_PIX(I,:),NOVAL)
CALL RESAMPLING_AVERAGE(PWV_MOD_BEF_DEF(I,:),NbMinute,IDELTA,PWV_MOD_BEF_PIX(I,:),NbPix,SD_PWV_MOD_BEF_PIX(I,:),NOVAL)
CALL RESAMPLING_AVERAGE(PWV_MOD_AFT_DEF(I,:),NbMinute,IDELTA,PWV_MOD_AFT_PIX(I,:),NbPix,SD_PWV_MOD_AFT_PIX(I,:),NOVAL)
ENDDO

PRINT*,'End of OBS data treatement'
!
!
ALLOCATE(PWV_OBS_PIX_LIM(NbNights,NbPix))
PWV_OBS_PIX_LIM(:,:)=NOVAL
ALLOCATE(PWV_MOD_BEF_PIX_LIM(NbNights,NbPix))
PWV_MOD_BEF_PIX_LIM(:,:)=NOVAL
ALLOCATE(PWV_MOD_AFT_PIX_LIM(NbNights,NbPix))
PWV_MOD_AFT_PIX_LIM(:,:)=NOVAL

DO I=1,NbNights
DO J=1,NbPix
IF(PWV_OBS_PIX(I,J).LT.MAXPWV)THEN
 PWV_OBS_PIX_LIM(I,J)=PWV_OBS_PIX(I,J)
 PWV_MOD_BEF_PIX_LIM(I,J)=PWV_MOD_BEF_PIX(I,J)
 PWV_MOD_AFT_PIX_LIM(I,J)=PWV_MOD_AFT_PIX(I,J)
ENDIF
ENDDO
ENDDO
!
NbLines_TOT_Pix=NbNights*NbPix
PRINT*,'NbLines_TOT_Pix=',NbLines_TOT_Pix

ALLOCATE(PWV_OBS_1D(NbLines_TOT_Pix))
ALLOCATE(PWV_MOD_BEF_1D(NbLines_TOT_Pix))
ALLOCATE(PWV_MOD_AFT_1D(NbLines_TOT_Pix))
PWV_OBS_1D(:)=NOVAL
PWV_MOD_BEF_1D(:)=NOVAL
PWV_MOD_AFT_1D(:)=NOVAL
!
K=0
DO I=1,NbNights
DO J=1,NbPix
 K=(I-1)*NbPix+J
 PWV_OBS_1D(K)=PWV_OBS_PIX_LIM(I,J)
 PWV_MOD_BEF_1D(K)=PWV_MOD_BEF_PIX_LIM(I,J)
 PWV_MOD_AFT_1D(K)=PWV_MOD_AFT_PIX_LIM(I,J)
! PRINT*,I,J,K,PWV_OBS_1D(K),PWV_MOD_BEF_1D(K),PWV_MOD_AFT_1D(K)
ENDDO
ENDDO
!
!
!OPEN(UNIT=92,FILE='prova_all.txt',FORM='FORMATTED',IOSTAT=IERR,STATUS='NEW',ACCESS='SEQUENTIAL')
!DO I=1,NbLines_TOT_Pix
!IF( (PWV_OBS_1D(I).NE.9999.).AND.(PWV_OBS_1D(I).NE.0.).AND.(PWV_MOD_BEF_1D(I).NE.0.).AND.(PWV_MOD_AFT_1D(I).NE.0.))THEN
!WRITE(92,*) I,PWV_OBS_1D(I),PWV_MOD_BEF_1D(I),PWV_MOD_AFT_1D(I)
!ENDIF
!ENDDO
!CLOSE(92)
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
MAXVAL_PWV_OBS_1D=MAXVAL(PWV_OBS_1D)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

PRINT*,'MAXVAL_PWV_OBS_1D=',MAXVAL_PWV_OBS_1D

ALLOCATE(PWV_OBS_1D_LIM(NbLines_TOT_Pix))
ALLOCATE(PWV_MOD_BEF_1D_LIM(NbLines_TOT_Pix))
ALLOCATE(PWV_MOD_AFT_1D_LIM(NbLines_TOT_Pix))
PWV_OBS_1D_LIM(:)=NOVAL
PWV_MOD_BEF_1D_LIM(:)=NOVAL
PWV_MOD_AFT_1D_LIM(:)=NOVAL
!
! we had introduced MAXVAL_PWV_OBS_1D to have the possibility to take seeing < 1.5 arcsec
! per PWV non serve ma e' rimnasto per omogenieta' con programmi per altri parametri
!
DO I=1,NbLines_TOT_Pix
IF(PWV_OBS_1D(I).LE.MAXVAL_PWV_OBS_1D)THEN
PWV_OBS_1D_LIM(I)=PWV_OBS_1D(I)
PWV_MOD_BEF_1D_LIM(I)=PWV_MOD_BEF_1D(I)
PWV_MOD_AFT_1D_LIM(I)=PWV_MOD_AFT_1D(I)
ENDIF
ENDDO
!
!
! Calculation of BIAS and RMSE
!
CALL BIAS_RMSE_SIGMA(PWV_OBS_1D_LIM,PWV_MOD_BEF_1D_LIM,NbLines_TOT_Pix,BIAS_PWV_MOD_BEF,RMSE_PWV_MOD_BEF, &
         SIGMA_PWV_MOD_BEF,INC_PWV_MOD_BEF,NOVAL)
PRINT*,'LOGINFO BIAS_PWV_MOD_BEF=',BIAS_PWV_MOD_BEF
PRINT*,'LOGINFO RMSE_PWV_MOD_BEF=',RMSE_PWV_MOD_BEF
PRINT*,'LOGINFO SIGMA_PWV_MOD_BEF=',SIGMA_PWV_MOD_BEF
PRINT*,'INC_PWV_MOD_BEF=',INC_PWV_MOD_BEF
PRINT*,'NbLines_TOT=',NbLines_TOT_Pix
WRITE(BIAS_MOD_BEFc,'(f5.2)')BIAS_PWV_MOD_BEF
WRITE(RMSE_MOD_BEFc,'(f5.2)')RMSE_PWV_MOD_BEF
WRITE(SIGMA_MOD_BEFc,'(f5.2)')SIGMA_PWV_MOD_BEF
!
CALL BIAS_RMSE_SIGMA(PWV_OBS_1D_LIM,PWV_MOD_AFT_1D_LIM,NbLines_TOT_Pix,BIAS_PWV_MOD_AFT,RMSE_PWV_MOD_AFT, &
         SIGMA_PWV_MOD_AFT,INC_PWV_MOD_AFT,NOVAL)
PRINT*,'LOGINFO BIAS_PWV_MOD_AFT=',BIAS_PWV_MOD_AFT
PRINT*,'LOGINFO RMSE_PWV_MOD_AFT=',RMSE_PWV_MOD_AFT
PRINT*,'LOGINFO SIGMA_PWV_MOD_AFT=',SIGMA_PWV_MOD_AFT
PRINT*,'INC_PWV_MOD_AFT=',INC_PWV_MOD_AFT
PRINT*,'NbLines_TOT=',NbLines_TOT_Pix
WRITE(BIAS_MOD_AFTc,'(f5.2)')BIAS_PWV_MOD_AFT
WRITE(RMSE_MOD_AFTc,'(f5.2)')RMSE_PWV_MOD_AFT
WRITE(SIGMA_MOD_AFTc,'(f5.2)')SIGMA_PWV_MOD_AFT
!
ICOUNT=0
DO I=1,NbLines_TOT_Pix
IF( (PWV_OBS_1D_LIM(I).NE.NOVAL).AND.(PWV_MOD_BEF_1D_LIM(I).NE.NOVAL).AND.(PWV_MOD_AFT_1D_LIM(I).NE.NOVAL) )THEN
ICOUNT=ICOUNT+1
ENDIF
ENDDO
NbFit=ICOUNT
PRINT*,'NbFit=',NbFit,'NbLines_TOT=',NbLines_TOT,'NbPix=',NbPix
!
ALLOCATE(PWV_OBS_1D_FIT(NbFit))
PWV_OBS_1D_FIT(:)=NOVAL
ALLOCATE(PWV_MOD_BEF_1D_FIT(NbFit))
PWV_MOD_BEF_1D_FIT(:)=NOVAL
ALLOCATE(PWV_MOD_AFT_1D_FIT(NbFit))
PWV_MOD_AFT_1D_FIT(:)=NOVAL
!
K=0
PRINT*,'K=',K
DO I=1,NbLines_TOT_Pix
IF( (PWV_OBS_1D_LIM(I).NE.NOVAL).AND.(PWV_MOD_BEF_1D_LIM(I).NE.NOVAL).AND.(PWV_MOD_AFT_1D_LIM(I).NE.NOVAL) )THEN
K=K+1
PWV_OBS_1D_FIT(K)=PWV_OBS_1D_LIM(I)
PWV_MOD_BEF_1D_FIT(K)=PWV_MOD_BEF_1D_LIM(I)
PWV_MOD_AFT_1D_FIT(K)=PWV_MOD_AFT_1D_LIM(I)
!PRINT*,'I=',I,'K=',K,PWV_OBS_1D_FIT(K),PWV_MOD_BEF_1D_FIT(K),PWV_MOD_AFT_1D_FIT(K)
ENDIF
ENDDO
!
!!!!!!!!!!!!!!!!!
! WRITE output file for python
!!!!!!!!!!!!!!!!!

OPEN(unit=90,file='out_scatter_for_python_bef.dat',form='formatted',status='new',access='append')
DO I=1,NbFit
WRITE(90,*) PWV_OBS_1D_FIT(I),PWV_MOD_BEF_1D_FIT(I)
ENDDO
CLOSE(90)

OPEN(unit=91,file='out_scatter_for_python_aft.dat',form='formatted',status='new',access='append')
DO I=1,NbFit
WRITE(91,*) PWV_OBS_1D_FIT(I),PWV_MOD_AFT_1D_FIT(I)
ENDDO
CLOSE(91)
!
! LINEAR REGRESSION
!
PRINT*,'#### FIT BEF ####'
CALL FIT_ORIG(PWV_OBS_1D_FIT,PWV_MOD_BEF_1D_FIT,B_MOD_BEF,SIGB_MOD_BEF,CHI2_MOD_BEF,Q_MOD_BEF)
PRINT*,'B_TOT(slope)=',B_MOD_BEF
WRITE(B_MOD_BEFc,'(f4.2)')B_MOD_BEF
WRITE(SIGB_MOD_BEFc,'(f4.2)')SIGB_MOD_BEF

PRINT*,'#### FIT AFT #####'
CALL FIT_ORIG(PWV_OBS_1D_FIT,PWV_MOD_AFT_1D_FIT,B_MOD_AFT,SIGB_MOD_AFT,CHI2_MOD_AFT,Q_MOD_AFT)
PRINT*,'B_TOT(slope)=',B_MOD_AFT
WRITE(B_MOD_AFTc,'(f4.2)')B_MOD_AFT
WRITE(SIGB_MOD_AFTc,'(f4.2)')SIGB_MOD_AFT
!

ALLOCATE(CDX_PWV(NbFit))
ALLOCATE(CDY_PWV(NbFit))
CDX_PWV=NOVAL
CDY_PWV=NOVAL

PRINT*,'***************'
CALL CUMDIST_TERTILES(NbFit,PWV_OBS_1D_FIT,CDX_PWV,CDY_PWV,XMED_PWV,X33_PWV,X66_PWV)
PRINT*,'XMED_PWV=',XMED_PWV
PRINT*,'X33_PWV=',X33_PWV
PRINT*,'X66_PWV=',X66_PWV
PRINT*,'***************'
!
ALLOCATE(CDX_MOD_BEF(NbFit))
ALLOCATE(CDY_MOD_BEF(NbFit))
CDX_MOD_BEF=NOVAL
CDY_MOD_BEF=NOVAL
PRINT*,'***************'
CALL CUMDIST_TERTILES(NbFit,PWV_MOD_BEF_1D_FIT,CDX_MOD_BEF,CDY_MOD_BEF,XMED_MOD_BEF,X33_MOD_BEF,X66_MOD_BEF)
PRINT*,'XMED_MOD_BEF=',XMED_MOD_BEF
PRINT*,'***************'
!
PRINT*,'##########################################'
PRINT*,'######## HIT_RATE for BEF ###########'
PRINT*,'##########################################'
!
! Calcultion of hit-rate using as extreme the first and thrid tertile of the PWV
! Attention: the hit_rate is calculated only in the case without filter i.e. MAXVALSEE=999.
!
POD=NOVAL
TAB_HR=NOVAL
CALL HIT_RATE(PWV_OBS_1D_FIT,PWV_MOD_BEF_1D_FIT,NbFit,X33_PWV,X66_PWV,NOVAL,TAB_HR,POD,PC,EBD,.false.)

ALLOCATE(CDX_MOD_AFT(NbFit))
ALLOCATE(CDY_MOD_AFT(NbFit))
CDX_MOD_AFT=NOVAL
CDY_MOD_AFT=NOVAL
PRINT*,'***************'
CALL CUMDIST_TERTILES(NbFit,PWV_MOD_AFT_1D_FIT,CDX_MOD_AFT,CDY_MOD_AFT,XMED_MOD_AFT,X33_MOD_AFT,X66_MOD_AFT)
PRINT*,'XMED_MOD_AFT=',XMED_MOD_AFT
PRINT*,'***************'
!
PRINT*,'##########################################'
PRINT*,'############ HIT_RATE for AFT #############'
PRINT*,'##########################################'
!
! Calcultion of hit-rate using as extreme the first and thrid tertile of the PWV
!
POD(:)=NOVAL
TAB_HR=NOVAL
CALL HIT_RATE(PWV_OBS_1D_FIT,PWV_MOD_AFT_1D_FIT,NbFit,X33_PWV,X66_PWV,NOVAL,TAB_HR,POD,PC,EBD,.false.)

!
!  Graphics
!

xmin=0.
xmax=15.
xhmin=0.
xhmax=15.
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
CALL PGLABEL('OBS: PWV (mm)','MNH: PWV (mm)','CLASSIC')
DO I=1,NbNights
 DO J=1,NbPix
   IF( (PWV_OBS_PIX_LIM(I,J).NE.0).AND.(PWV_MOD_BEF_PIX_LIM(I,J).NE.0)&
       .AND.(PWV_OBS_PIX_LIM(I,J).LE.MAXVAL_PWV_OBS_1D))THEN
   CALL PGSLW(4)
   CALL PGPT(1,PWV_OBS_PIX_LIM(I,J),PWV_MOD_BEF_PIX_LIM(I,J),-1)
   ENDIF
 ENDDO
ENDDO
   CALL PGSCH(1.5)
   CALL PGSLW(2)
   CALL PGSLS(2)
   CALL PGLINE(NB_UNITY_X,UNITY,UNITY)
   CALL PGSLS(1)
   CALL PGSCI(1)
   CALL PGTEXT(xmax*0.05,xhmax*0.9,'BIAS='//BIAS_MOD_BEFc)
   CALL PGTEXT(xmax*0.05,xhmax*0.85,'RMSE='//RMSE_MOD_BEFc)
   CALL PGTEXT(xmax*0.05,xhmax*0.8,'sigma='//SIGMA_MOD_BEFc)
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
CALL PGLABEL('OBS: PWV (mm)','MNH: PWV (mm)','WITH AR')
DO I=1,NbNights
 DO J=1,NbPix
   IF( (PWV_OBS_PIX_LIM(I,J).NE.0).AND.(PWV_MOD_AFT_PIX_LIM(I,J).NE.0)&
       .AND.(PWV_OBS_PIX_LIM(I,J).LE.MAXVAL_PWV_OBS_1D))THEN
   CALL PGSLW(4)
   CALL PGPT(1,PWV_OBS_PIX_LIM(I,J),PWV_MOD_AFT_PIX_LIM(I,J),-1)
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
