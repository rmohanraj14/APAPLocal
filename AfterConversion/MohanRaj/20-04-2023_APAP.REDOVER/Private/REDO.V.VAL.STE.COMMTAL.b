* @ValidationCode : MjoxMzk4OTE4MjU3OkNwMTI1MjoxNjgxOTc0OTA0ODU4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:45:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.VAL.STE.COMMTAL
*------------------------------------------------------------------------------
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: S SUDHARSANAN
* PROGRAM NAME: REDO.V.VAL.STE.COMMTAL
* ODR NO : ODR-2009-12-0275
*----------------------------------------------------------------------
* DESCRIPTION: This routine will populate the value for the field
* L.STE.COMMTAL has to be brought automatically from the field COMMISSION
* in the table REDO.H.MOD.CHEQUERA
* IN PARAMETER:NONE
* OUT PARAMETER:NONE
* LINKED WITH:STOCK.ENTRY,REDO.PERSONALIZACION
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE WHO REFERENCE DESCRIPTION
*15.02.2010 S SUDHARSANAN ODR-2009-12-0275 INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,++ TO +=1
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STOCK.ENTRY
    $INSERT I_F.REDO.H.MOD.CHEQUERA
    GOSUB INIT
    GOSUB PROCESS
RETURN
******
INIT:
******
    FN.STOCK.ENTRY='F.STOCK.ENTRY'
    F.STOCK.ENTRY=''
    CALL OPF(FN.STOCK.ENTRY,F.STOCK.ENTRY)
    FN.REDO.H.MOD.CHEQUERA='F.REDO.H.MOD.CHEQUERA'
    F.REDO.H.MOD.CHEQUERA=''
    CALL OPF(FN.REDO.H.MOD.CHEQUERA,F.REDO.H.MOD.CHEQUERA)
    STE.COMM.POS=''
    CALL GET.LOC.REF("STOCK.ENTRY",'L.STE.COMMTAL',STE.COMM.POS)
RETURN
********
PROCESS:
*********
* Default the field L.STE.COMMTAL

    MOD.CHEQ.ID = COMI
    CALL F.READ(FN.REDO.H.MOD.CHEQUERA,MOD.CHEQ.ID,R.REDO.H.MOD.CHEQUERA,F.REDO.H.MOD.CHEQUERA,CHEQ.ERR)
    IF CHEQ.ERR EQ '' THEN
        COMM.CNT=DCOUNT(R.REDO.H.MOD.CHEQUERA<REDO.H.MOD.COMMISSION>,@VM)
        COMM.POS=1
        LOOP
        WHILE COMM.POS LE COMM.CNT
            R.NEW(STO.ENT.LOCAL.REF)<1,STE.COMM.POS,COMM.POS> = R.REDO.H.MOD.CHEQUERA<REDO.H.MOD.COMMISSION,COMM.POS>
            COMM.POS += 1
        REPEAT
    END
RETURN
*------------------------------------------------------------------
END
