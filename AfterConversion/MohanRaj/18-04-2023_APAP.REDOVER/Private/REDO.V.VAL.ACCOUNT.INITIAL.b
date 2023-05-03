* @ValidationCode : Mjo0NjI3Nzk5NjM6Q3AxMjUyOjE2ODE4MTYyNjc3MTE6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:41:07
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
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.VAL.ACCOUNT.INITIAL
*------------------------------------------------------------------------------------------
*DESCRIPTION : This is a no file enquiry routine for the enquiry NOFILE.REDO.INS.PAYMENTS
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN : -NA-
* OUT : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : HARISH.Y
* PROGRAM NAME : REDO.V.VAL.ACCOUNT.INITIAL
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE WHO REFERENCE DESCRIPTION
* 24.06.2010 HARISH.Y ODR-2009-10-0340 INITIAL CREATION
* -----------------------------------------------------------------------------------------
* -----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACCOUNT

    GOSUB INIT
    GOSUB PROCESS
RETURN
*----------
INIT:
*---------
    CALL GET.LOC.REF('AA.ARR.ACCOUNT',POLICY.STATUS,POL.STAT.POS)
RETURN

*----------
PROCESS:
*----------

    R.NEW(AA.AC.LOCAL.REF)<1,POL.STAT.POS> = 'CURRENT'
RETURN
END
