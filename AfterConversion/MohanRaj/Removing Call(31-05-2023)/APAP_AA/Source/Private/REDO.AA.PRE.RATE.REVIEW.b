* @ValidationCode : Mjo4MjQ0NjA4Nzg6Q3AxMjUyOjE2ODU1MjgzODY3NTI6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 15:49:46
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
$PACKAGE APAP.AA
SUBROUTINE REDO.AA.PRE.RATE.REVIEW

*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.AA.PRE.RATE.REVIEW
*--------------------------------------------------------------------------------
* Description:  This is a pre routine for lending new arrangement activity for interst
* property to check Rate review freq will be mandatory when Type of Rate Review field
* has value PERIODIC
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE            DESCRIPTION
* 20-May-2011     H GANESH   PACS00055012 - B.16    INITIAL CREATION
* 10-10-2011     JEEVA T     PACS00136838 - B.16    RATE review freq is changed
* 29-03-2023          CONVERSTION TOOL     R22 AUTO CONVERSTION VM TO @VM
* 29-03-2023          ANIL KUMAR B         R22 MANUAL CONVERSTION CALL method format changed
*--------------------------------------------------------------------------------------
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_AA.LOCAL.COMMON

    GOSUB INIT
    GOSUB PROCESS
RETURN
*---------------------------------------------------------------------------------
INIT:
*---------------------------------------------------------------------------------

    LOC.REF.APPLICATION="AA.PRD.DES.INTEREST"
    LOC.REF.FIELDS='L.AA.REV.RT.TY':@VM:'L.AA.RT.RV.FREQ':@VM:'L.AA.FIR.REV.DT'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AA.REV.RT.TY=LOC.REF.POS<1,1>
    POS.L.AA.RT.RV.FREQ=LOC.REF.POS<1,2>
    POS.L.AA.FRST.RV.FREQ=LOC.REF.POS<1,3>

RETURN
*---------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------
    Y.RATE.TYPE=R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.REV.RT.TY>
    Y.RATE.REVIEW.FREQ=R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.RT.RV.FREQ>
    Y.RATE.REVIEW.FREQ=R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.FRST.RV.FREQ>

    IF Y.RATE.TYPE EQ 'PERIODICO' THEN
        IF Y.RATE.REVIEW.FREQ EQ '' THEN
            AF=AA.INT.LOCAL.REF
            AV=POS.L.AA.RT.RV.FREQ
            ETEXT='EB-REDO.RATE.REV.FREQ'
            CALL STORE.END.ERROR
            RETURN
        END
        GOSUB GET.MATURITY.DATE
        IF Y.RATE.REVIEW.FREQ GT Y.MATURITY.DATE THEN
            ETEXT = 'LD-CANNOT.BE.GT.THAN.MATURITY.DATE'
            AF = AA.INT.LOCAL.REF
            AV = POS.L.AA.FRST.RV.FREQ
            CALL STORE.END.ERROR
            RETURN
        END


    END



RETURN
*---------------------------------------------------------------------------------
GET.MATURITY.DATE:
*---------------------------------------------------------------------------------
    ARR.ID = c_aalocArrId
    EFF.DATE = ''
    PROP.CLASS='TERM.AMOUNT'
    PROPERTY = ''
    R.CONDITION = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion
    Y.MATURITY.DATE=R.CONDITION<AA.AMT.MATURITY.DATE>
RETURN
END
