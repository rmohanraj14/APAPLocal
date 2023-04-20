* @ValidationCode : MjoyNDA0NjIxODc6Q3AxMjUyOjE2ODE5NzMzNjI4NDc6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:19:22
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
SUBROUTINE REDO.V.VAL.ORD.DELI
*-----------------------------------------------------------------------------
* Description:
* This routine will be attached to the version REDO.ORDER.DETAIL,ORDER.DELEVIRY as
* a validation routine
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* * Input / Output
*
* --------------
* IN     : -NA-
* OUT    : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : MARIMUTHU S
* PROGRAM NAME : REDO.V.VAL.ORD.DELI
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO            REFERENCE         DESCRIPTION
* 12.04.2010  MARIMUTHU S     ODR-2009-11-0200  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* -----------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.H.ORDER.DETAILS
*----------------------------------------------------------------------------------------
MAIN:
*----------------------------------------------------------------------------------------
    GOSUB OPENFILES
    GOSUB PROCESS
    GOSUB PROGRAM.END
*----------------------------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------------------------
    FN.REDO.H.ORDER.DETAILS = 'F.REDO.H.ORDER.DETAILS'
    F.REDO.H.ORDER.DETAILS = ''
    CALL OPF(FN.REDO.H.ORDER.DETAILS,F.REDO.H.ORDER.DETAILS)

RETURN
*----------------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------------------
    Y.ORDER.REFERENCE = COMI

    SEL.CMD = 'SELECT ':FN.REDO.H.ORDER.DETAILS:' WITH ORDER.REFERENCE EQ ':Y.ORDER.REFERENCE
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.RECS,ORD.ERR)

    CALL F.READ(FN.REDO.H.ORDER.DETAILS,SEL.LIST,R.REDO.H.ORDER.DETAILS,F.REDO.H.ORDER.DETAILS,ORD.DET.ERR)


    R.NEW(RE.ORD.DATE) = R.REDO.H.ORDER.DETAILS<RE.ORD.DATE>
    R.NEW(RE.ORD.REQUEST.COMPANY) = R.REDO.H.ORDER.DETAILS<RE.ORD.REQUEST.COMPANY>
    R.NEW(RE.ORD.DESCRIPTION) = R.REDO.H.ORDER.DETAILS<RE.ORD.DESCRIPTION>
    R.NEW(RE.ORD.ITEM.CODE) = R.REDO.H.ORDER.DETAILS<RE.ORD.ITEM.CODE>
    R.NEW(RE.ORD.REQUEST.QUANTITY) = R.REDO.H.ORDER.DETAILS<RE.ORD.REQUEST.QUANTITY>
    R.NEW(RE.ORD.DELEVIRY.DATE) = R.REDO.H.ORDER.DETAILS<RE.ORD.DELEVIRY.DATE>
    R.NEW(RE.ORD.ORDER.STATUS) = 'Delivered Order'

RETURN
*----------------------------------------------------------------------------------------
PROGRAM.END:
*----------------------------------------------------------------------------------------
END
