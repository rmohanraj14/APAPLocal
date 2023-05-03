* @ValidationCode : MjoxMTgzODc3MjYyOkNwMTI1MjoxNjgxNzI4MjY1NzcyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:14:25
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
*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE REDO.V.INP.DIS.BILL.COND
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This routine will check the mandatory fields
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : @ID
* CALLED BY :
*
* Revision History:
*------------------------------------------------------------------------------------------
*   Date               who           Reference          Description
* 05-03-2011        SUDHARSANAN S  PACS00033084       Initial Creation
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     No changes
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.THIRDPRTY.PARAMETER
    IF VAL.TEXT NE "" THEN
        GOSUB INIT
        GOSUB PROCESS
    END
RETURN
*---*
INIT:
*---*
    FN.REDO.THIRDPRTY.PARAMETER = 'F.REDO.THIRDPRTY.PARAMETER'
    F.REDO.THIRDPRTY.PARAMETER = ''
    CALL OPF(FN.REDO.THIRDPRTY.PARAMETER,F.REDO.THIRDPRTY.PARAMETER)
RETURN
*------*
PROCESS:
*------*
    VAR.BILL.TYPE = R.NEW(REDO.TP.BILL.TYPE)
    IF NOT(VAR.BILL.TYPE) THEN
        AF = REDO.TP.BILL.TYPE
        ETEXT = 'EB-INPUT.MISSING'
        CALL STORE.END.ERROR
    END
    VAR.BILL.COND  =  R.NEW(REDO.TP.BILL.COND)
    CHANGE @VM TO @FM IN VAR.BILL.COND
    CNT.BILL.COND = DCOUNT(VAR.BILL.COND,@FM)
    FOR CNT =1 TO CNT.BILL.COND
        VAL.BILL.COND  = VAR.BILL.COND<CNT>
        IF NOT(VAL.BILL.COND) THEN
            AF = REDO.TP.BILL.COND
            AV = CNT
            ETEXT = 'EB-INPUT.MISSING'
            CALL STORE.END.ERROR
        END
    NEXT CNT
RETURN
*---------------------------------
END
