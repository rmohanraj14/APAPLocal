* @ValidationCode : MjotMjA0OTY0NjQ0ODpDcDEyNTI6MTY4MTgxMjI3NzcwMDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Apr 2023 15:34:37
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
SUBROUTINE REDO.V.ITEM.DESC.DISP
*-----------------------------------------------------------------------------
* Description:
* This routine will be attached to the versions as
* a validation routine
*------------------------------------------------------------------------------------------
* * Input / Output
*
* --------------
* IN     : -NA-
* OUT    : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : MARIMUTHU S
* PROGRAM NAME : REDO.V.ITEM.REQ.DESC
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO            REFERENCE         DESCRIPTION
* 12.04.2010  MARIMUTHU S     ODR-2009-11-0200  INITIAL CREATION
* 11-07-2011  JEEVA T         ODR-2009-11-0200  PACS00063147
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.H.ORDER.DETAILS
    $INSERT I_F.REDO.H.ITEM.DETAILS
    $INSERT I_F.REDO.H.INVENTORY.PARAMETER
    $INSERT I_F.REDO.ISSUE.DEPT.CODE
    $INSERT I_F.REDO.H.REORDER.LEVEL
    $INSERT I_F.REDO.H.MAIN.COMPANY
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    IF MESSAGE EQ 'VAL' THEN
        RETURN
    END
    GOSUB OPENFILES
    IF APPLICATION EQ 'REDO.H.INVENTORY.PARAMETER' THEN
        GOSUB PROCESS
    END
    IF APPLICATION EQ 'REDO.H.REORDER.LEVEL' THEN
        GOSUB PROCESS.NEW
    END

    IF APPLICATION EQ 'REDO.H.MAIN.COMPANY' THEN
        GOSUB PROCESS.MULTI.COMPANY
    END

    GOSUB PROGRAM.END
RETURN
*-----------------------------------------------------------------------------
OPENFILES:
*-----------------------------------------------------------------------------

    FN.REDO.H.ORDER.DETAILS = 'F.REDO.H.ORDER.DETAILS'
    F.REDO.H.ORDER.DETAILS = ''
    CALL OPF(FN.REDO.H.ORDER.DETAILS,F.REDO.H.ORDER.DETAILS)

    FN.REDO.H.ITEM.DETAILS = 'F.REDO.H.ITEM.DETAILS'
    F.REDO.H.ITEM.DETAILS = ''
    CALL OPF(FN.REDO.H.ITEM.DETAILS,F.REDO.H.ITEM.DETAILS)

    FN.REDO.H.INVENTORY.PARAMETER = 'F.REDO.H.INVENTORY.PARAMETER'
    F.REDO.H.INVENTORY.PARAMETER = ''
    CALL OPF(FN.REDO.H.INVENTORY.PARAMETER,F.REDO.H.INVENTORY.PARAMETER)

    FN.REDO.ISSUE.DEPT.CODE = 'F.REDO.ISSUE.DEPT.CODE'
    F.REDO.ISSUE.DEPT.CODE = ''
    CALL OPF(FN.REDO.ISSUE.DEPT.CODE,F.REDO.ISSUE.DEPT.CODE)

    Y.ID = 'SYSTEM'
    CALL CACHE.READ(FN.REDO.H.ITEM.DETAILS,Y.ID,R.REDO.H.ITEM.DETAILS,IT.DET.ERR)

RETURN
*-----------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------

    Y.DESC = COMI
    IF Y.DESC THEN

        Y.SUPPLY.CODES = R.REDO.H.ITEM.DETAILS<IT.DT.SUPPLY.CODE>
        Y.SUPPLY.CODES = CHANGE(Y.SUPPLY.CODES,@VM,@FM)


        LOCATE Y.DESC IN Y.SUPPLY.CODES SETTING POS THEN
            Y.SUPPLY.CODE = R.REDO.H.ITEM.DETAILS<IT.DT.DESCRIPTION,POS>
            R.NEW(IN.PR.ITEM.DESC)<1,AV> = Y.SUPPLY.CODE
        END

    END ELSE
        R.NEW(IN.PR.ITEM.DESC)<1,AV> = ''
    END
RETURN
*------------------------------------------------------------------------------
PROCESS.NEW:
*------------------------------------------------------------------------------

    Y.DESC = COMI
    IF Y.DESC THEN
        Y.SUPPLY.CODES = R.REDO.H.ITEM.DETAILS<IT.DT.SUPPLY.CODE>
        Y.SUPPLY.CODES = CHANGE(Y.SUPPLY.CODES,@VM,@FM)


        LOCATE Y.DESC IN Y.SUPPLY.CODES SETTING POS THEN
            Y.SUPPLY.CODE = R.REDO.H.ITEM.DETAILS<IT.DT.DESCRIPTION,POS>
            R.NEW(RE.ORD.ITEM.DESC)<1,AV,AS> = Y.SUPPLY.CODE
        END

    END ELSE
        R.NEW(RE.ORD.ITEM.DESC)<1,AV,AS> = ''
    END
RETURN

*------------------------------------------------------------------------------
PROCESS.MULTI.COMPANY:
*------------------------------------------------------------------------------

    Y.DESC = COMI
    IF Y.DESC THEN
        CALL F.READ(FN.REDO.ISSUE.DEPT.CODE,Y.DESC,R.REDO.ISSUE.DEPT.CODE,F.REDO.ISSUE.DEPT.CODE,Y.ERR)
        R.NEW(REDO.COM.DESCRIPTION)<1,AV> = R.REDO.ISSUE.DEPT.CODE<REDO.IDC.ISSUE.DEPT.NAME>
    END ELSE
        R.NEW(REDO.COM.DESCRIPTION)<1,AV> = ''
    END
RETURN
*-----------------------------------------------------------------------------
PROGRAM.END:
END
*-------------------------------------------------------------------------
