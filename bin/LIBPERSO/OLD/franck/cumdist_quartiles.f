CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C  Subroutine de calcul de la distribution cumulee des valeurs de F
C  ENTREE:F:tableau de dimension N
C         N: dimension de F
C  SORTIE: CDX: abscissa de la distribution cumulee
C          CDY: ordonnees de la distribution cumulee
C          xmed: mediane
C  F et CDX peuvent etre le meme tableau lors de l'appel
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      subroutine cumdist_quartiles(N,F,CDX,CDY,XMED,X25,X75)
      integer N,indx(N)
      dimension F(N),CDX(N),CDY(N),AUX(N)

      call indexx (N,F,indx)
      AUX=F
      CDX=AUX(indx)
      N2=N/2
      N3=N/4
      N4=3*N/4
      do i=1,N
         CDY(i)=(real(i-1)/real(N-1))
      enddo
      if(2*N2.eq.N)then
         XMED=0.5*(CDX(N2)+CDX(N2+1))
      else
         XMED=CDX(N2+1)  
      endif
      if(4*N3.eq.N)then
         X25=0.5*(CDX(N3)+CDX(N3+1))
      else
         X25=CDX(N3+1)
      endif
      if((4./3.)*N4.eq.N)then
         X75=0.5*(CDX(N4)+CDX(N4+1))
      else
         X75=CDX(N4+1)
      endif
c
c  equivalemment, au lieu du XMED construit comme ca
c  on peut le definir aussi
c
c
c            XMED=CDX(N2)+((0.5-CDY(N2))*(CDX(N2+1)-CDX(N2))
c     1   /(CDY(N2+1)-CDY(N2)))
c
c
      return
      end
