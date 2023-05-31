* @ValidationCode : MjoxMjgxOTA2Nzc6Q3AxMjUyOjE2ODAwNzEwODI5Mjc6SVRTUzotMTotMTowOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 29 Mar 2023 11:54:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.V.ANC.AA.DEP.REF

*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Pradeep S
* Program Name  : REDO.V.ANC.AA.DEP.REF
*-------------------------------------------------------------------------
* Description: This ANC routine to default THEIR.REFERENCE field with AA id.
*-------------------------------------------------------------------------
* Linked with   :
* In parameter  :
* out parameter : None
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*------------------------------------------------------------------------
* DATE         Name          ODR / HD REF              DESCRIPTION
* 14-09-12     Pradeep S     PACS00183693              Initial creation
** 30-03-2023 R22 Auto Conversion
** 30-03-2023 Skanda R22 Manual Conversion - No changes

*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_System
    $INSERT I_F.ACCOUNT
    $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER

    GOSUB INIT
*GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

PROCESS:
*********

    Y.ACCT.ID = System.getVariable("CURRENT.AA.ID")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;** R22 Auto Conversion
        Y.ACCT.ID = "" ;** R22 Auto Conversion
    END ;** R22 Auto Conversion

*IF Y.ACCT.ID THEN
*GOSUB READ.ACCT
*END

    BEGIN CASE

        CASE APPLICATION EQ "TELLER"
*IF Y.AA.FLAG THEN
            R.NEW(TT.TE.THEIR.REFERENCE) = Y.ACCT.ID
*END

    END CASE

RETURN

READ.ACCT:
***********

    R.ACC = ''
    CALL F.READ(FN.ACCT,Y.ACCT.ID,R.ACC,F.ACCT,ERR.ACC)
    IF R.ACC THEN
        Y.AA.FLAG = @TRUE
        Y.AA.ID = R.ACC<AC.ARRANGEMENT.ID>
    END
RETURN

INIT:
******

    Y.AA.FLAG = @FALSE
    Y.ACCT.ID = ''

RETURN

OPEN.FILES:
************

    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
    CALL OPF(FN.ACCT,F.ACCT)

RETURN

END
