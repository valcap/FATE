program test

  use mod_read_ar

  implicit none
  integer :: i
  integer :: ARcol,ARlength,MNHlength,TELlength
  integer :: nminread,nminbase
  character(480) :: datestring,filename1,filename2,filename3,fileout,namevar
  real, parameter :: noval=9999.
  real, dimension(:,:), allocatable :: variableAR,variableMNH,variableTEL
  
  print*, '#########################################'
  print*, 'DATE'
  read(5,*) datestring
  print*, trim(datestring)
  print*, 'AR FILE:'
  read(5,*) filename1
  print*, trim(filename1)
  print*, 'MNH FILE:'
  read(5,*) filename2
  print*, trim(filename2)
  print*, 'TELEMETRY FILE:'
  read(5,*) filename3
  print*, trim(filename3)
  print*, 'NMINREADMAX:'
  read(5,*) nminread
  print*, nminread
  print*, 'NMINREADMIN:'
  read(5,*) nminbase
  print*, nminbase
  print*, 'NAMEVAR:'
  read(5,*) namevar
  print*, trim(namevar)
  print*, 'OUTPUT FILE:'
  read(5,*) fileout
  print*, trim(fileout)

!IN ALL ARRAYS READ FROM FILES, FIRST COLUMN IS TIME IN MINUTES, SECOND COLUMN IS THE VARIABLE

  print*,"******* READ AR"
  call read_arfile_extremes(filename1,nminbase,nminread,variableAR)
  ARlength=size(variableAR,1)
  ARcol=size(variableAR,2)

  print*, 'size1=',ARlength
  print*, 'size2=',ARcol
  do i=1,2
    print*, variableAR(i,:)
  end do
  do i=size(variableAR,1)-1,size(variableAR,1)
    print*, variableAR(i,:)
  end do

  print*,"******* READ MNH"

  call read_datafile_fromar(filename2,variableAR,noval,variableMNH)
  MNHlength=size(variableMNH,1)

  print*, 'size1=',MNHlength
  print*, 'size2=',size(variableMNH,2)
  do i=1,2
    print*, variableMNH(i,:)
  end do
  do i=size(variableMNH,1)-1,size(variableMNH,1)
    print*, variableMNH(i,:)
  end do

  print*,"******* READ TELEMETRY"

  call read_datafile_fromar(filename3,variableAR,noval,variableTEL)
  TELlength=size(variableTEL,1)  

  print*, 'size1=',TELlength
  print*, 'size2=',size(variableTEL,2)
  do i=1,2
    print*, variableTEL(i,:)
  end do
  do i=size(variableTEL,1)-1,size(variableTEL,1)
    print*, variableTEL(i,:)
  end do

  if (ARlength.ne.MNHlength) then
    print*, 'ERROR: ARlength=',ARlength,' while MNHlength=',MNHlength
    call exit(1)
  end if
  if (ARlength.ne.TELlength) then
    print*, 'ERROR: ARlength=',ARlength,' while TELlength=',TELlength
    call exit(1)
  end if

  print*,"******* WRITE OUTPUT"  

  open(UNIT=79,FILE=fileout,FORM='FORMATTED',STATUS='NEW',ACCESS='APPEND')
  write(79,*) trim(datestring)
  write(79,*) 'Seconds  Measures('//trim(namevar)//')  Meso-NH('//trim(namevar)//')  FORECAST_AR('//trim(namevar)//')'
  do i=1,ARlength
!    if (int(variableAR(i,1))*60 <= 64740) then
      write(79,*) int(variableAR(i,1))*60,variableTEL(i,2),variableMNH(i,2),variableAR(i,2)
!    end if
  end do
  close(79)

  print*, '#########################################'

end program test
