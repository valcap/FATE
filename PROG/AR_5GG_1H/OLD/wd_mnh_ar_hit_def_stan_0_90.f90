program ws_mnh_ar

use mod_scienceperso

implicit none

INTEGER,PARAMETER                    :: NbMinute=1080 ! 18h=1080minutes
REAL,PARAMETER                       :: NOVAL=0.
CHARACTER(180),ALLOCATABLE,DIMENSION(:)   :: CFILE_DATE,CFILE_DATE_WS
CHARACTER(8),ALLOCATABLE,DIMENSION(:)     :: DATE
CHARACTER(120)                       :: PUBEL,PGPLOT1,PGPLOT2,CFILE_LIST_NIGHTS
CHARACTER(3)                         :: GG
CHARACTER(2)                         :: HH
INTEGER                              :: IDELTA,NbPix,K,J,I,IERR,NbLines_TOT,NbLines_TOT_Pix,ICOUNT
INTEGER                              :: NbFit,NB_UNITY_X,NB_UNITY_Y
INTEGER                              :: INC_MOD_AFT,INC_MOD_BEF
INTEGER                              :: NbNights,STARTMINUTE,ENDMINUTE
REAL                                 :: xmin,xmax,xhmin,xhmax
REAL                                 :: B_MOD_AFT,SIGB_MOD_AFT,CHI2_MOD_AFT,Q_MOD_AFT
REAL                                 :: B_MOD_BEF,SIGB_MOD_BEF,CHI2_MOD_BEF,Q_MOD_BEF
REAL                                 :: LIMIT
!REAL                                 :: XMED_WD,X33_WD,X66_WD
!REAL                                 :: XMED_MOD_BEF,X33_MOD_BEF,X66_MOD_BEF
!REAL                                 :: XMED_MOD_AFT,X33_MOD_AFT,X66_MOD_AFT,PC,EBD
REAL                                 :: BIAS_WD_MOD_AFT,RMSE_WD_MOD_AFT,SIGMA_WD_MOD_AFT,PC,EBD
REAL                                 :: BIAS_WD_MOD_BEF,RMSE_WD_MOD_BEF,SIGMA_WD_MOD_BEF
CHARACTER(6)                         :: B_MOD_AFTc,B_MOD_BEFc,SIGB_MOD_AFTc,SIGB_MOD_BEFc
CHARACTER(6)                         :: BIAS_WD_MOD_BEFc,BIAS_WD_MOD_AFTc
CHARACTER(6)                         :: RMSE_WD_MOD_BEFc,SIGMA_WD_MOD_BEFc,RMSE_WD_MOD_AFTc,SIGMA_WD_MOD_AFTc
CHARACTER(180)                       :: ROOT,ROOT_WS
CHARACTER(40)                        :: START,START_WS,TAIL,STARTIN,STARTIN_WS
INTEGER,ALLOCATABLE,DIMENSION(:)          :: NbLines
INTEGER,DIMENSION(:,:),ALLOCATABLE :: SECONDS,MINUTE,MINUTE_DEF
INTEGER,DIMENSION(:,:),ALLOCATABLE :: INC_WD_OBS_PIX,INC_WD_MOD_BEF_PIX,INC_WD_MOD_AFT_PIX
REAL,DIMENSION(:,:),ALLOCATABLE    :: WD_OBS_VX,WD_MOD_BEF_VX,WD_MOD_AFT_VX
REAL,DIMENSION(:,:),ALLOCATABLE    :: WD_OBS_VY,WD_MOD_BEF_VY,WD_MOD_AFT_VY
REAL,DIMENSION(:,:),ALLOCATABLE    :: WD_OBS_VX_DEF,WD_MOD_BEF_VX_DEF,WD_MOD_AFT_VX_DEF
REAL,DIMENSION(:,:),ALLOCATABLE    :: WD_OBS_VY_DEF,WD_MOD_BEF_VY_DEF,WD_MOD_AFT_VY_DEF
REAL,DIMENSION(:,:),ALLOCATABLE    :: WD_OBS_PIX,WD_MOD_BEF_PIX,WD_MOD_AFT_PIX
REAL,DIMENSION(:,:),ALLOCATABLE    :: WS_OBS_PIX,SD_WS_OBS_PIX,WD_OBS_PIX_LIM,WD_MOD_BEF_PIX_LIM
REAL,DIMENSION(:,:),ALLOCATABLE    :: WD_MOD_AFT_PIX_LIM
REAL,DIMENSION(:,:),ALLOCATABLE    :: SD_WD_OBS_PIX,SD_WD_MOD_BEF_PIX,SD_WD_MOD_AFT_PIX
REAL,DIMENSION(:,:),ALLOCATABLE    :: WS_OBS,WS_OBS_DEF,WS_MOD_BEF,WS_MOD_AFT
REAL,DIMENSION(:),ALLOCATABLE      :: WD_OBS_1D,WD_MOD_BEF_1D,WD_MOD_AFT_1D,UNITY
REAL,DIMENSION(:),ALLOCATABLE      :: WD_OBS_1D_FIT,WD_MOD_BEF_1D_FIT,WD_MOD_AFT_1D_FIT
!REAL,DIMENSION(:),ALLOCATABLE      :: CDX_WD,CDY_WD,CDX_MOD_BEF,CDY_MOD_BEF,CDX_MOD_AFT,CDY_MOD_AFT
REAL,DIMENSION(4,4)                   :: TAB_HR
REAL,DIMENSION(4)                     :: POD

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
READ(5,*) LIMIT
PRINT*, 'LIMIT=',LIMIT
READ(5,*) ROOT
PRINT*, 'ROOT=',TRIM(ROOT)
READ(5,*) ROOT_WS
PRINT*, 'ROOT_WS=',TRIM(ROOT_WS)
READ(5,*) TAIL
PRINT*, 'TAIL=',TRIM(TAIL)
READ(5,*) STARTIN
PRINT*, 'STARTIN=',TRIM(STARTIN)
READ(5,*) STARTIN_WS
PRINT*, 'STARTIN_WS=',TRIM(STARTIN_WS)
READ (5,*) CFILE_LIST_NIGHTS
PRINT*, 'CFILE_LIST_NIGHTS=',CFILE_LIST_NIGHTS
READ (5,*)PGPLOT1
PRINT*, PGPLOT1
READ (5,*)PGPLOT2
PRINT*, PGPLOT2

ALLOCATE(CFILE_DATE(NbNights))
ALLOCATE(CFILE_DATE_WS(NbNights))
ALLOCATE(DATE(NbNights))
ALLOCATE(NbLines(NbNights))

START=TRIM(STARTIN)//TRIM(HH)//"_"//TRIM(GG)//"_"
PRINT*,TRIM(START)

START_WS=TRIM(STARTIN_WS)//TRIM(HH)//"_"//TRIM(GG)//"_"
PRINT*,TRIM(START_WS)

DO I=1,NbNights
OPEN(UNIT=90,FILE=CFILE_LIST_NIGHTS,FORM='FORMATTED',IOSTAT=IERR,STATUS='OLD',ACCESS='SEQUENTIAL')
READ(90,*) DATE(I)
ENDDO
CLOSE(90)

DO I=1,NbNights
CFILE_DATE(I)=TRIM(ROOT)//TRIM(START)//TRIM(DATE(I))//TRIM(TAIL)
!PRINT*,CFILE_DATE(I)
ENDDO

DO I=1,NbNights
CFILE_DATE_WS(I)=TRIM(ROOT_WS)//TRIM(START_WS)//TRIM(DATE(I))//TRIM(TAIL)
!PRINT*,CFILE_DATE(I)
ENDDO
!
! NbLines is the same for WS and WD
!
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
!
! Calcolo il massimo anche se tutti i files hanno lo stesso numero di linee
!
NbLines_TOT=MAXVAL(NbLines)
PRINT*,'NbLines_TOT=',NbLines_TOT
!
ALLOCATE(SECONDS(NbNights,NbLines_TOT))
ALLOCATE(MINUTE(NbNights,NbLines_TOT))
ALLOCATE(WD_OBS_VX(NbNights,NbLines_TOT))
ALLOCATE(WD_OBS_VY(NbNights,NbLines_TOT))
ALLOCATE(WD_MOD_BEF_VX(NbNights,NbLines_TOT))
ALLOCATE(WD_MOD_BEF_VY(NbNights,NbLines_TOT))
ALLOCATE(WD_MOD_AFT_VX(NbNights,NbLines_TOT))
ALLOCATE(WD_MOD_AFT_VY(NbNights,NbLines_TOT))
SECONDS(:,:)=int(NOVAL)
MINUTE(:,:)=int(NOVAL)
WD_OBS_VX(:,:)=NOVAL
WD_OBS_VY(:,:)=NOVAL
WD_MOD_BEF_VX(:,:)=NOVAL
WD_MOD_BEF_VY(:,:)=NOVAL
WD_MOD_AFT_VX(:,:)=NOVAL
WD_MOD_AFT_VY(:,:)=NOVAL

DO I=1,NbNights
OPEN(UNIT=90,FILE=CFILE_DATE(I),FORM='FORMATTED',STATUS='OLD',ACCESS='SEQUENTIAL')
  READ(90,*) PUBEL
  READ(90,*) PUBEL
    DO J=1,NbLines(I)
    READ(90,*) SECONDS(I,J),WD_OBS_VX(I,J),WD_OBS_VY(I,J),WD_MOD_BEF_VX(I,J),&
               WD_MOD_BEF_VY(I,J),WD_MOD_AFT_VX(I,J),WD_MOD_AFT_VY(I,J)
!    PRINT*,SECONDS(I,J),WD_OBS_VX(I,J),WD_OBS_VY(I,J),WD_MOD_BEF_VX(I,J),&
!               WD_MOD_BEF_VY(I,J),WD_MOD_AFT_VX(I,J),WD_MOD_AFT_VY(I,J)
    if((SECONDS(I,J) .ne.INT(NOVAL)).AND.(WD_OBS_VX(I,J).ne.9999.).AND.(WD_OBS_VY(I,J).ne.9999.))then
    MINUTE(I,J)=SECONDS(I,J)/60
    else
    MINUTE(I,J)=int(NOVAL)
    WD_OBS_VX(I,J)=NOVAL
    WD_OBS_VY(I,J)=NOVAL
    WD_MOD_BEF_VX(I,J)=NOVAL
    WD_MOD_BEF_VY(I,J)=NOVAL
    WD_MOD_AFT_VX(I,J)=NOVAL
    WD_MOD_AFT_VY(I,J)=NOVAL
    end if
    if((SECONDS(I,J) .lt. STARTMINUTE) .or. (SECONDS(I,J) .gt. ENDMINUTE))  then
    WD_OBS_VX(I,J)=NOVAL
    WD_OBS_VY(I,J)=NOVAL
    WD_MOD_BEF_VX(I,J)=NOVAL
    WD_MOD_BEF_VY(I,J)=NOVAL
    WD_MOD_AFT_VX(I,J)=NOVAL
    WD_MOD_AFT_VY(I,J)=NOVAL
    endif
    ENDDO
CLOSE(90)
ENDDO
!
!  Reading of the WS
!
ALLOCATE(WS_OBS(NbNights,NbLines_TOT))
ALLOCATE(WS_MOD_BEF(NbNights,NbLines_TOT))
ALLOCATE(WS_MOD_AFT(NbNights,NbLines_TOT))
SECONDS(:,:)=int(NOVAL)
MINUTE(:,:)=int(NOVAL)
WS_OBS(:,:)=NOVAL
WS_MOD_BEF(:,:)=NOVAL
WS_MOD_AFT(:,:)=NOVAL
!
DO I=1,NbNights
OPEN(UNIT=90,FILE=CFILE_DATE_WS(I),FORM='FORMATTED',STATUS='OLD',ACCESS='SEQUENTIAL')
  READ(90,*) PUBEL
  READ(90,*) PUBEL
    DO J=1,NbLines(I)
    READ(90,*) SECONDS(I,J),WS_OBS(I,J),WS_MOD_BEF(I,J),WS_MOD_AFT(I,J)
    if((SECONDS(I,J) .ne.INT(NOVAL)).AND.(WS_OBS(I,J).ne.9999.))then
    MINUTE(I,J)=SECONDS(I,J)/60
    else
    MINUTE(I,J)=int(NOVAL)
    WS_OBS(I,J)=NOVAL
    WS_MOD_BEF(I,J)=NOVAL
    WS_MOD_AFT(I,J)=NOVAL
    end if
    if((SECONDS(I,J) .lt. STARTMINUTE) .or. (SECONDS(I,J) .gt. ENDMINUTE))  then
    WS_OBS(I,J)=NOVAL
    WS_MOD_BEF(I,J)=NOVAL
    WS_MOD_AFT(I,J)=NOVAL
    endif
    ENDDO
CLOSE(90)
ENDDO
!
ALLOCATE(WS_OBS_DEF(NbNights,NbMinute))
ALLOCATE(MINUTE_DEF(NbNights,NbMinute))
WS_OBS_DEF(:,:)=NOVAL
MINUTE_DEF(:,:)=int(NOVAL)

DO I=1,NbNights
DO J=1,NbLines(I)
IF(MINUTE(I,J).NE.0)THEN
MINUTE_DEF(I,MINUTE(I,J))=MINUTE(I,J)
WS_OBS_DEF(I,MINUTE(I,J))=WS_OBS(I,J)
ENDIF
ENDDO
ENDDO
!
ALLOCATE(WD_OBS_VX_DEF(NbNights,NbMinute))
ALLOCATE(WD_OBS_VY_DEF(NbNights,NbMinute))
ALLOCATE(WD_MOD_BEF_VX_DEF(NbNights,NbMinute))
ALLOCATE(WD_MOD_BEF_VY_DEF(NbNights,NbMinute))
ALLOCATE(WD_MOD_AFT_VX_DEF(NbNights,NbMinute))
ALLOCATE(WD_MOD_AFT_VY_DEF(NbNights,NbMinute))
WD_OBS_VX_DEF(:,:)=NOVAL
WD_OBS_VY_DEF(:,:)=NOVAL
WD_MOD_BEF_VX_DEF(:,:)=NOVAL
WD_MOD_BEF_VY_DEF(:,:)=NOVAL
WD_MOD_AFT_VX_DEF(:,:)=NOVAL
WD_MOD_AFT_VY_DEF(:,:)=NOVAL

DO I=1,NbNights
DO J=1,NbLines(I)
IF(MINUTE(I,J).NE.0)THEN
WD_OBS_VX_DEF(I,MINUTE(I,J))=WD_OBS_VX(I,J)
WD_OBS_VY_DEF(I,MINUTE(I,J))=WD_OBS_VY(I,J)
WD_MOD_BEF_VX_DEF(I,MINUTE(I,J))=WD_MOD_BEF_VX(I,J)
WD_MOD_BEF_VY_DEF(I,MINUTE(I,J))=WD_MOD_BEF_VY(I,J)
WD_MOD_AFT_VX_DEF(I,MINUTE(I,J))=WD_MOD_AFT_VX(I,J)
WD_MOD_AFT_VY_DEF(I,MINUTE(I,J))=WD_MOD_AFT_VY(I,J)
ENDIF
ENDDO
ENDDO

PRINT*,'MINUTE_DEF(1,1)=',MINUTE_DEF(1,1),'MINUTE_DEF(1,869)=',MINUTE_DEF(1,869)

ALLOCATE(WS_OBS_PIX(NbNights,NbPix))
WS_OBS_PIX(:,:)=NOVAL
ALLOCATE(SD_WS_OBS_PIX(NbNights,NbPix))
SD_WS_OBS_PIX(:,:)=NOVAL

ALLOCATE(WD_OBS_PIX(NbNights,NbPix))
WD_OBS_PIX(:,:)=NOVAL
ALLOCATE(SD_WD_OBS_PIX(NbNights,NbPix))
SD_WD_OBS_PIX(:,:)=NOVAL
ALLOCATE(INC_WD_OBS_PIX(NbNights,NbPix))
INC_WD_OBS_PIX(:,:)=NOVAL

ALLOCATE(WD_MOD_BEF_PIX(NbNights,NbPix))
WD_MOD_BEF_PIX(:,:)=NOVAL
ALLOCATE(SD_WD_MOD_BEF_PIX(NbNights,NbPix))
SD_WD_MOD_BEF_PIX(:,:)=NOVAL
ALLOCATE(INC_WD_MOD_BEF_PIX(NbNights,NbPix))
INC_WD_MOD_BEF_PIX(:,:)=NOVAL

ALLOCATE(WD_MOD_AFT_PIX(NbNights,NbPix))
WD_MOD_AFT_PIX(:,:)=NOVAL
ALLOCATE(SD_WD_MOD_AFT_PIX(NbNights,NbPix))
SD_WD_MOD_AFT_PIX(:,:)=NOVAL
ALLOCATE(INC_WD_MOD_AFT_PIX(NbNights,NbPix))
INC_WD_MOD_AFT_PIX(:,:)=NOVAL
!
!
DO I=1,NbNights
CALL RESAMPLING_AVERAGE_WIND_DIRECTION(WD_OBS_VX_DEF(I,:),WD_OBS_VY_DEF(I,:),NbMinute,IDELTA,&
              WD_OBS_PIX(I,:),NbPix,SD_WD_OBS_PIX(I,:),NOVAL)
CALL RESAMPLING_AVERAGE_WIND_DIRECTION(WD_MOD_BEF_VX_DEF(I,:),WD_MOD_BEF_VY_DEF(I,:),NbMinute,IDELTA,&
            WD_MOD_BEF_PIX(I,:),NbPix,SD_WD_MOD_BEF_PIX(I,:),NOVAL)
CALL RESAMPLING_AVERAGE_WIND_DIRECTION(WD_MOD_AFT_VX_DEF(I,:),WD_MOD_AFT_VY_DEF(I,:),NbMinute,IDELTA,&
            WD_MOD_AFT_PIX(I,:),NbPix,SD_WD_MOD_AFT_PIX(I,:),NOVAL)
CALL RESAMPLING_AVERAGE(WS_OBS_DEF(I,:),NbMinute,IDELTA,WS_OBS_PIX(I,:),NbPix,SD_WS_OBS_PIX(I,:),NOVAL)
ENDDO
PRINT*,'End of OBS data treatement'

!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  FILTER (0ms-1, 3ms-1, ...)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!LIMIT=3.
!
ALLOCATE(WD_OBS_PIX_LIM(NbNights,NbPix))
WD_OBS_PIX_LIM(:,:)=NOVAL
ALLOCATE(WD_MOD_BEF_PIX_LIM(NbNights,NbPix))
WD_MOD_BEF_PIX_LIM(:,:)=NOVAL
ALLOCATE(WD_MOD_AFT_PIX_LIM(NbNights,NbPix))
WD_MOD_AFT_PIX_LIM(:,:)=NOVAL

DO I=1,NbNights
DO J=1,NbPix
IF(WS_OBS_PIX(I,J).GT.LIMIT)THEN
 WD_OBS_PIX_LIM(I,J)=WD_OBS_PIX(I,J)
 WD_MOD_BEF_PIX_LIM(I,J)=WD_MOD_BEF_PIX(I,J)
 WD_MOD_AFT_PIX_LIM(I,J)=WD_MOD_AFT_PIX(I,J)
ENDIF
ENDDO
ENDDO
!

NbLines_TOT_Pix=NbNights*NbPix
PRINT*,'NbLines_TOT_Pix=',NbLines_TOT_Pix

ALLOCATE(WD_OBS_1D(NbLines_TOT_Pix))
ALLOCATE(WD_MOD_BEF_1D(NbLines_TOT_Pix))
ALLOCATE(WD_MOD_AFT_1D(NbLines_TOT_Pix))
WD_OBS_1D(:)=NOVAL
WD_MOD_BEF_1D(:)=NOVAL
WD_MOD_AFT_1D(:)=NOVAL
!
K=0
DO I=1,NbNights
DO J=1,NbPix
 K=(I-1)*NbPix+J
 WD_OBS_1D(K)=WD_OBS_PIX_LIM(I,J)
 WD_MOD_BEF_1D(K)=WD_MOD_BEF_PIX_LIM(I,J)
 WD_MOD_AFT_1D(K)=WD_MOD_AFT_PIX_LIM(I,J)
! PRINT*,I,J,K,WD_OBS_1D(K),WD_MOD_BEF_1D(K),WD_MOD_AFT_1D(K)
ENDDO
ENDDO
!
!
!OPEN(UNIT=92,FILE='prova_all.txt',FORM='FORMATTED',IOSTAT=IERR,STATUS='NEW',ACCESS='SEQUENTIAL')
!DO I=1,NbLines_TOT_Pix
!IF( (WD_OBS_1D(I).NE.9999.).AND.(WD_OBS_1D(I).NE.0.).AND.(WD_MOD_BEF_1D(I).NE.0.).AND.(WD_MOD_AFT_1D(I).NE.0.))THEN
!WRITE(92,*) I,WD_OBS_1D(I),WD_MOD_BEF_1D(I),WD_MOD_AFT_1D(I)
!ENDIF
!ENDDO
!CLOSE(92)
!
!
!
! Calculation of BIAS and RMSE
!
CALL BIAS_RMSE_SIGMA_WIND_DIRECTION(WD_OBS_1D,WD_MOD_BEF_1D,NbLines_TOT_Pix,BIAS_WD_MOD_BEF,RMSE_WD_MOD_BEF, &
         SIGMA_WD_MOD_BEF,INC_MOD_BEF,NOVAL)
WRITE (*,1003) 'LOGINFO BIAS_WD_MOD_BEF=',BIAS_WD_MOD_BEF
WRITE (*,1003) 'LOGINFO RMSE_WD_MOD_BEF=',RMSE_WD_MOD_BEF
WRITE (*,1003) 'LOGINFO SIGMA_WD_MOD_BEF=',SIGMA_WD_MOD_BEF
PRINT*,'INC_MOD_BEF=',INC_MOD_BEF
PRINT*,'NbLines_TOT=',NbLines_TOT_Pix
WRITE(BIAS_WD_MOD_BEFc,'(f5.2)')BIAS_WD_MOD_BEF
WRITE(RMSE_WD_MOD_BEFc,'(f5.2)')RMSE_WD_MOD_BEF
WRITE(SIGMA_WD_MOD_BEFc,'(f5.2)')SIGMA_WD_MOD_BEF
!
CALL BIAS_RMSE_SIGMA_WIND_DIRECTION(WD_OBS_1D,WD_MOD_AFT_1D,NbLines_TOT_Pix,BIAS_WD_MOD_AFT,RMSE_WD_MOD_AFT, &
         SIGMA_WD_MOD_AFT,INC_MOD_AFT,NOVAL)
WRITE (*,1003) 'LOGINFO BIAS_WD_MOD_AFT=',BIAS_WD_MOD_AFT
WRITE (*,1003) 'LOGINFO RMSE_WD_MOD_AFT=',RMSE_WD_MOD_AFT
WRITE (*,1003) 'LOGINFO SIGMA_WD_MOD_AFT=',SIGMA_WD_MOD_AFT
PRINT*,'INC_MOD_AFT=',INC_MOD_AFT
PRINT*,'NbLines_TOT=',NbLines_TOT_Pix
WRITE(BIAS_WD_MOD_AFTc,'(f5.2)')BIAS_WD_MOD_AFT
WRITE(RMSE_WD_MOD_AFTc,'(f5.2)')RMSE_WD_MOD_AFT
WRITE(SIGMA_WD_MOD_AFTc,'(f5.2)')SIGMA_WD_MOD_AFT
!
ICOUNT=0
DO I=1,NbLines_TOT_Pix
IF( (WD_OBS_1D(I).NE.0).AND.(WD_MOD_BEF_1D(I).NE.0).AND.(WD_MOD_AFT_1D(I).NE.0) )THEN
ICOUNT=ICOUNT+1
ENDIF
ENDDO
NbFit=ICOUNT
PRINT*,'NbFit=',NbFit,'NbLines_TOT=',NbLines_TOT,'NbPix=',NbPix
!
ALLOCATE(WD_OBS_1D_FIT(NbFit))
WD_OBS_1D_FIT(:)=NOVAL
ALLOCATE(WD_MOD_BEF_1D_FIT(NbFit))
WD_MOD_BEF_1D_FIT(:)=NOVAL
ALLOCATE(WD_MOD_AFT_1D_FIT(NbFit))
WD_MOD_AFT_1D_FIT(:)=NOVAL
!
K=0
PRINT*,'K=',K
DO I=1,NbLines_TOT_Pix
IF( (WD_OBS_1D(I).NE.NOVAL).AND.(WD_MOD_BEF_1D(I).NE.NOVAL).AND.(WD_MOD_AFT_1D(I).NE.NOVAL) )THEN
K=K+1
WD_OBS_1D_FIT(K)=WD_OBS_1D(I)
WD_MOD_BEF_1D_FIT(K)=WD_MOD_BEF_1D(I)
WD_MOD_AFT_1D_FIT(K)=WD_MOD_AFT_1D(I)
!PRINT*,'I=',I,'K=',K,WD_OBS_1D_FIT(K),WD_MOD_BEF_1D_FIT(K),WD_MOD_AFT_1D_FIT(K)
ENDIF
ENDDO
!
!!!!!!!!!!!!!!!!!
! WRITE output file for python
!!!!!!!!!!!!!!!!!

OPEN(unit=90,file='out_scatter_for_python_bef.dat',form='formatted',status='new',access='append')
DO I=1,NbFit
WRITE(90,*) WD_OBS_1D_FIT(I),WD_MOD_BEF_1D_FIT(I)
ENDDO
CLOSE(90)

OPEN(unit=91,file='out_scatter_for_python_aft.dat',form='formatted',status='new',access='append')
DO I=1,NbFit
WRITE(91,*) WD_OBS_1D_FIT(I),WD_MOD_AFT_1D_FIT(I)
ENDDO
CLOSE(91)
!
! LINEAR REGRESSION
!
PRINT*,'#### FIT BEF ####'
CALL FIT_ORIG(WD_OBS_1D_FIT,WD_MOD_BEF_1D_FIT,B_MOD_BEF,SIGB_MOD_BEF,CHI2_MOD_BEF,Q_MOD_BEF)
PRINT*,'B_TOT(slope)=',B_MOD_BEF
WRITE(B_MOD_BEFc,'(f4.2)')B_MOD_BEF
WRITE(SIGB_MOD_BEFc,'(f4.2)')SIGB_MOD_BEF

PRINT*,'#### FIT AFT #####'
CALL FIT_ORIG(WD_OBS_1D_FIT,WD_MOD_AFT_1D_FIT,B_MOD_AFT,SIGB_MOD_AFT,CHI2_MOD_AFT,Q_MOD_AFT)
PRINT*,'B_TOT(slope)=',B_MOD_AFT
WRITE(B_MOD_AFTc,'(f4.2)')B_MOD_AFT
WRITE(SIGB_MOD_AFTc,'(f4.2)')SIGB_MOD_AFT
!
! CUMDIST non funziona con funzioni circolari
!
!ALLOCATE(CDX_WD(NbFit))
!ALLOCATE(CDY_WD(NbFit))
!CDX_WD=NOVAL
!CDY_WD=NOVAL

!PRINT*,'***************'
!CALL CUMDIST_TERTILES(NbFit,WD_OBS_1D_FIT,CDX_WD,CDY_WD,XMED_WD,X33_WD,X66_WD)
!PRINT*,'XMED_WD=',XMED_WD
!PRINT*,'X33_WD=',X33_WD
!PRINT*,'X66_WD=',X66_WD
!PRINT*,'***************'
!
!ALLOCATE(CDX_MOD_BEF(NbFit))
!ALLOCATE(CDY_MOD_BEF(NbFit))
!CDX_MOD_BEF=NOVAL
!CDY_MOD_BEF=NOVAL
!PRINT*,'***************'
!CALL CUMDIST_TERTILES(NbFit,WD_MOD_BEF_1D_FIT,CDX_MOD_BEF,CDY_MOD_BEF,XMED_MOD_BEF,X33_MOD_BEF,X66_MOD_BEF)
!PRINT*,'XMED_MOD_BEF=',XMED_MOD_BEF
!PRINT*,'X33_MOD_BEF=',X33_MOD_BEF
!PRINT*,'X66_MOD_BEF=',X66_MOD_BEF
!PRINT*,'***************'
!
! I have to rotate values that are larger than 315 degrees becaus I am analyziing data between -45 and + 45 degrees
!
!DO I=1,NbFit
!IF(WD_OBS_1D_FIT(I).GT.315.)THEN
!    WD_OBS_1D_FIT(I)=WD_OBS_1D_FIT(I)-360.
!ENDIF
!IF(WD_MOD_BEF_1D_FIT(I).GT.315.)THEN
!    WD_MOD_BEF_1D_FIT(I)=WD_MOD_BEF_1D_FIT(I)-360.
!ENDIF
!ENDDO
!
PRINT*,'##########################################'
PRINT*,'######## HIT_RATE for BEF ###########'
PRINT*,'##########################################'
!
! Calcultion of hit-rate using as extreme the first and thrid tertile of the WD
! Attention: the hit_rate is calculated only in the case without filter i.e. MAXVALSEE=999.
!
POD=NOVAL
TAB_HR=NOVAL
CALL HIT_RATE_QUART(WD_OBS_1D_FIT,WD_MOD_BEF_1D_FIT,NbFit,90.,180.,270.,NOVAL,TAB_HR,POD,PC,EBD,.false.)
!CALL HIT_RATE_QUART(WD_OBS_1D_FIT,WD_MOD_BEF_1D_FIT,NbFit,45.,135.,225.,NOVAL,TAB_HR,POD,PC,EBD,.false.)
!
!
!ALLOCATE(CDX_MOD_AFT(NbFit))
!ALLOCATE(CDY_MOD_AFT(NbFit))
!CDX_MOD_AFT=NOVAL
!CDY_MOD_AFT=NOVAL
!PRINT*,'***************'
!CALL CUMDIST_TERTILES(NbFit,WD_MOD_AFT_1D_FIT,CDX_MOD_AFT,CDY_MOD_AFT,XMED_MOD_AFT,X33_MOD_AFT,X66_MOD_AFT)
!PRINT*,'XMED_MOD_AFT=',XMED_MOD_AFT
!PRINT*,'X33_MOD_AFT=',X33_MOD_AFT
!PRINT*,'X66_MOD_AFT=',X66_MOD_AFT
!PRINT*,'***************'
!
!
PRINT*,'##########################################'
PRINT*,'############ HIT_RATE for AFT #############'
PRINT*,'##########################################'
!
! Calcultion of hit-rate using as extreme the first and thrid tertile of the WD
!
POD(:)=NOVAL
TAB_HR=NOVAL
CALL HIT_RATE_QUART(WD_OBS_1D_FIT,WD_MOD_AFT_1D_FIT,NbFit,90.,180.,270.,NOVAL,TAB_HR,POD,PC,EBD,.false.)
!CALL HIT_RATE_QUART(WD_OBS_1D_FIT,WD_MOD_AFT_1D_FIT,NbFit,45.,135.,225.,NOVAL,TAB_HR,POD,PC,EBD,.false.)

! OUTPUT FORMATS
1001 format (a200,2x,f7.1)
1002 format (a200,2x,f7.2)
1003 format (a200,2x,f7.3)
1005 format (a200,2x,f7.5)
3001 format (a200,3(2x,I5))
5000 format (a200,2x,f4.1,2x,f4.1,a3,2x,f4.1,a2,f4.1)

!
!  Graphics
!

xmin=0.
xmax=360.
xhmin=0.
xhmax=360.

NB_UNITY_X=INT(xmax)*200
NB_UNITY_Y=INT(xhmax)*200

ALLOCATE(UNITY(NB_UNITY_X))
UNITY(:)=0

DO I=1,NB_UNITY_X
UNITY(I)=I*0.01
ENDDO
!
CALL PGBEGIN(0,PGPLOT1,2,2)
CALL PGSCH(1.5)
CALL PGSLW(3)  ! paper
CALL PGENV(xmin,xmax,xhmin,xhmax,1,0)
CALL PGLABEL('OBS: WD (deg)','MNH: WD (deg)','STANDARD CONFIGURATION')
DO I=1,NbNights
 DO J=1,NbPix
    IF( (WD_OBS_PIX_LIM(I,J).NE.0).AND.(WD_MOD_BEF_PIX_LIM(I,J).NE.0))THEN
    CALL PGSLW(4)
    IF(ABS((WD_OBS_PIX_LIM(I,J)-WD_MOD_BEF_PIX_LIM(I,J))).LT.180.) CALL PGPT(1,WD_OBS_PIX_LIM(I,J),WD_MOD_BEF_PIX_LIM(I,J),-1)
    IF(ABS((WD_OBS_PIX_LIM(I,J)-WD_MOD_BEF_PIX_LIM(I,J))).GT.180.) THEN
       IF(WD_OBS_PIX_LIM(I,J).GT.WD_MOD_BEF_PIX_LIM(I,J)) CALL PGPT(1,WD_OBS_PIX_LIM(I,J)-360.,WD_MOD_BEF_PIX_LIM(I,J),-1)
       IF(WD_OBS_PIX_LIM(I,J).LT.WD_MOD_BEF_PIX_LIM(I,J)) CALL PGPT(1,WD_OBS_PIX_LIM(I,J)+360.,WD_MOD_BEF_PIX_LIM(I,J),-1)
    ENDIF
   ENDIF
 ENDDO
ENDDO
   CALL PGSLW(2)
   CALL PGSLS(2)
   CALL PGLINE(NB_UNITY_X,UNITY,UNITY)
   CALL PGSLS(1)
   CALL PGSCI(1)
   CALL PGTEXT(xmax*0.05,xhmax*0.9,'BIAS='//BIAS_WD_MOD_BEFc)
   CALL PGTEXT(xmax*0.05,xhmax*0.85,'RMSE='//RMSE_WD_MOD_BEFc)
   CALL PGTEXT(xmax*0.05,xhmax*0.8,'sigma='//SIGMA_WD_MOD_BEFc)
   CALL PGTEXT(xmax*0.70,xhmax*0.12,'y=Bx')
   CALL PGTEXT(xmax*0.70,xhmax*0.07,'B='//B_MOD_BEFc)
   CALL PGSLW(3)
   CALL PGLINE(NB_UNITY_X,UNITY,B_MOD_BEF*UNITY)
   CALL PGSCI(1)
CALL PGEND

CALL PGBEGIN(0,PGPLOT2,2,2)
CALL PGSCH(1.5)
CALL PGSLW(3)  ! paper
CALL PGENV(xmin,xmax,xhmin,xhmax,1,0)
CALL PGLABEL('OBS: WD (deg)','MNH: WD (deg)','WITH AR')
DO I=1,NbNights
 DO J=1,NbPix
   IF( (WD_OBS_PIX_LIM(I,J).NE.0).AND.(WD_MOD_AFT_PIX_LIM(I,J).NE.0))THEN
     CALL PGSLW(4)
     IF(ABS((WD_OBS_PIX_LIM(I,J)-WD_MOD_AFT_PIX_LIM(I,J))).LT.180.) CALL PGPT(1,WD_OBS_PIX_LIM(I,J),WD_MOD_AFT_PIX_LIM(I,J),-1)
     IF(ABS((WD_OBS_PIX_LIM(I,J)-WD_MOD_AFT_PIX_LIM(I,J))).GT.180.) THEN
       IF(WD_OBS_PIX_LIM(I,J).GT.WD_MOD_AFT_PIX_LIM(I,J)) CALL PGPT(1,WD_OBS_PIX_LIM(I,J)-360.,WD_MOD_AFT_PIX_LIM(I,J),-1)
       IF(WD_OBS_PIX_LIM(I,J).LT.WD_MOD_AFT_PIX_LIM(I,J)) CALL PGPT(1,WD_OBS_PIX_LIM(I,J)+360.,WD_MOD_AFT_PIX_LIM(I,J),-1)
     ENDIF
   ENDIF
 ENDDO
ENDDO
   CALL PGSLW(2)
   CALL PGSLS(2)
   CALL PGLINE(NB_UNITY_X,UNITY,UNITY)
   CALL PGSLS(1)
   CALL PGSCI(1)
   CALL PGTEXT(xmax*0.05,xhmax*0.9,'BIAS='//BIAS_WD_MOD_AFTc)
   CALL PGTEXT(xmax*0.05,xhmax*0.85,'RMSE='//RMSE_WD_MOD_AFTc)
   CALL PGTEXT(xmax*0.05,xhmax*0.8,'sigma='//SIGMA_WD_MOD_AFTc)
   CALL PGTEXT(xmax*0.70,xhmax*0.12,'y=Bx')
   CALL PGTEXT(xmax*0.70,xhmax*0.07,'B='//B_MOD_AFTc)
   CALL PGSLW(3)
   CALL PGLINE(NB_UNITY_X,UNITY,B_MOD_AFT*UNITY)
   CALL PGSCI(1)
CALL PGEND

end program
