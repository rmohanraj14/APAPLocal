* @ValidationCode : MjotMjcwNzgyMDg1OkNwMTI1MjoxNjgxMzkwNDE0NDY1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:23:34
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
SUBROUTINE REDO.V.CHK.SINGLE.OVERDUE
*-------------------------------------------------------------------------------------------
*DESCRIPTION:
*             This routine is attached as validation routine for the field Arrangement in FUNDS.TRANSFER,AA.LS.LC.ACPO
* This routine displays the override message when all the bills are paid
* ------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 07-JUN-2010   N.Satheesh Kumar   ODR-2009-10-0331      Initial Creation
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM,VM TO @VM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*---------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_GTS.COMMON
    $INSERT I_EB.TRANS.COMMON


    IF OFS$OPERATION EQ 'VALIDATE' THEN
        RETURN
    END
*Return in Commit stage
    IF cTxn_CommitRequests EQ '1' THEN
        RETURN
    END





    IF MESSAGE EQ 'VAL' THEN
        RETURN
    END

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN

*----
INIT:
*----
*-------------------------------------------------
* This section initialises the necessary variables
*-------------------------------------------------

    ARR.ID = ECOMI
    R.AA.ACCOUNT.DETAILS = ''
    DUE.FLAG = 0
RETURN

*----------
OPEN.FILES:
*----------
*---------------------------------------
* This section opens the necessary files
*---------------------------------------

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)
RETURN

*-------
PROCESS:
*-------
*-------------------------------------------------------
* This section checks whether any bill is yet to be paid
*-------------------------------------------------------

    CALL APAP.REDOVER.REDO.V.DEF.FT.LOAN.STATUS.COND
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AC.DET.ERR)
    BILL.ID.LST = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    CHANGE @SM TO @VM IN BILL.ID.LST
    LOOP
        REMOVE BILL.ID FROM BILL.ID.LST SETTING BILL.ID.POS
    WHILE BILL.ID:BILL.ID.POS
        CALL F.READ(FN.AA.BILL.DETAILS,BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.DET.ERR)
        SETTLE.STATUS = R.AA.BILL.DETAILS<AA.BD.SETTLE.STATUS>
        IF 'UNPAID' MATCHES SETTLE.STATUS THEN
            DUE.FLAG = 1
            BREAK
        END
    REPEAT
    IF NOT(DUE.FLAG) THEN
        TEXT = "Para completar el proceso de cancelacisn de su pristamo, "
        TEXT := "debe dirigirse a cualquiera de nuestras oficinas."
        CURR.NO = DCOUNT(R.NEW(FT.OVERRIDE),@VM)
        IF CURR.NO EQ 0 THEN
            CURR.NO = 1
        END
        CALL STORE.OVERRIDE(CURR.NO)
    END
RETURN
END
