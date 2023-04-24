* @ValidationCode : Mjo4MzE4Njg5MDg6Q3AxMjUyOjE2ODEyMTU0MzY5ODc6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:47:16
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.UPD.LOAN.PAYOFF.DATE
* Correction routine to update the concat file REDO.LOAN.PAYOFF.DATE
* PACS00208729
*----------------------------------------------------------------------------
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,++ TO +=1
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.CUSTOMER.ARRANGEMENT
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $INSERT I_F.ALTERNATE.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACTIVITY.HISTORY

    GOSUB INIT
    GOSUB PROCESS

    CALL JOURNAL.UPDATE('')

RETURN

******
INIT:
******
*Initialise all the variable

    FN.CUS.ARR = 'F.REDO.CUSTOMER.ARRANGEMENT'
    F.CUS.ARR = ''
    CALL OPF(FN.CUS.ARR,F.CUS.ARR)

    FN.ALTER.ACCT = 'F.ALTERNATE.ACCOUNT'
    F.ALTER.ACCT  = ''
    CALL OPF(FN.ALTER.ACCT,F.ALTER.ACCT)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.REDO.APAP.PROPERTY = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY = ''
    CALL OPF(FN.REDO.APAP.PROPERTY,F.REDO.APAP.PROPERTY)

    FN.AA.ACT.HIS = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACT.HIS = ''
    CALL OPF(FN.AA.ACT.HIS,F.AA.ACT.HIS)

    FN.REDO.LOAN.PAYOFF.DATE = 'F.REDO.LOAN.PAYOFF.DATE'
    F.REDO.LOAN.PAYOFF.DATE = ''
    CALL OPF(FN.REDO.LOAN.PAYOFF.DATE,F.REDO.LOAN.PAYOFF.DATE)

    R.REDO.LOAN.PAYOFF.DATE = ''

RETURN
*********
PROCESS:
*********
    SEL.CMD = "SELECT ":FN.CUS.ARR:" WITH CLOSED NE ''"
    SEL.LIST = ''
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NOR,ERR)
    LOOP
        REMOVE Y.CUS.ID FROM SEL.LIST SETTING POS
    WHILE Y.CUS.ID:POS
        R.CUS.ARR = ''
        CALL F.READ(FN.CUS.ARR,Y.CUS.ID,R.CUS.ARR,F.CUS.ARR,CUS.ERR)
        CLOSED.ACCOUNT = R.CUS.ARR<CUS.ARR.CLOSED>
        CHANGE @VM TO @FM IN CLOSED.ACCOUNT
        GOSUB CHECK.CLOSE.ACCT
    REPEAT
RETURN
*-------------------------------------------------
CHECK.CLOSE.ACCT:
*-------------------------------------------------
    LOOP
        REMOVE Y.CLOS.ACC.ID FROM CLOSED.ACCOUNT SETTING CL.POS
    WHILE Y.CLOS.ACC.ID:CL.POS
        GOSUB UPD.PAYOFF.DATE
    REPEAT
RETURN
*-------------------------------------------------
CHECK.PAYOFF.DATE:
*------------------------------------------------
    CALL F.READ(FN.AA.ARRANGEMENT,Y.ARR.ID,R.AA.ARR,F.AA.ARRANGEMENT,AA.ARR.ERR)

    Y.PRODUCT.GROUP.ID = R.AA.ARR<AA.ARR.PRODUCT.GROUP>
    CALL F.READ(FN.REDO.APAP.PROPERTY,Y.PRODUCT.GROUP.ID,R.REDO.APAP.PROPERTY,F.REDO.APAP.PROPERTY,PROP.ERR)

    Y.PAYOFF.ACTIVITY =  R.REDO.APAP.PROPERTY<PROP.PARAM.PAYOFF.ACTIVITY>
    Y.CNT.PO = DCOUNT(Y.PAYOFF.ACTIVITY,@VM)

    CALL F.READ(FN.AA.ACT.HIS,Y.ARR.ID,R.AA.ACT.HIS,F.AA.ACT.HIS,ACT.ERR)

    VAR.EFF.DATE = R.AA.ACT.HIS<AA.AH.EFFECTIVE.DATE>
    VAR.ACTIVITY = R.AA.ACT.HIS<AA.AH.ACTIVITY>
    CNT.EFF.DATE = DCOUNT(VAR.EFF.DATE,@VM)
    CNT  = 1
    LOOP
    WHILE CNT LE CNT.EFF.DATE
        Y.ACT.ID = VAR.ACTIVITY<1,CNT> ; FLG = '' ; Y.CNT.PO = DCOUNT(Y.PAYOFF.ACTIVITY,@VM)
        LOOP
        WHILE Y.CNT.PO GT 0 DO
            FLG += 1
            Y.POF.AC = Y.PAYOFF.ACTIVITY<1,FLG>
            LOCATE Y.POF.AC IN Y.ACT.ID<1,1,1> SETTING ACT.POS THEN
                Y.PAYOFF.DATE = VAR.EFF.DATE<1,CNT>
                CNT = CNT.EFF.DATE+1
                Y.CNT.PO = 0
            END
            Y.CNT.PO -= 1
        REPEAT
        CNT += 1
    REPEAT

RETURN
*-------------------------------
UPD.PAYOFF.DATE:
*--------------------------------
    SEL.GLO.CMD = "SELECT ":FN.ALTER.ACCT:" WITH GLOBUS.ACCT.NUMBER EQ ":Y.CLOS.ACC.ID
    SEL.GLO.LIST = '' ; Y.ARR.ID = '' ; R.REDO.LOAN.PAYOFF.DATE = ''
    CALL EB.READLIST(SEL.GLO.CMD,SEL.GLO.LIST,'',NOR,ERR)
    Y.ARR.ID = SEL.GLO.LIST
    IF Y.ARR.ID THEN
        GOSUB CHECK.PAYOFF.DATE
        Y.ID =  Y.CLOS.ACC.ID
        Y.VALUE = Y.ARR.ID:"-":Y.PAYOFF.DATE
        R.REDO.LOAN.PAYOFF.DATE = Y.VALUE
        CALL F.WRITE(FN.REDO.LOAN.PAYOFF.DATE,Y.ID,R.REDO.LOAN.PAYOFF.DATE)
    END
RETURN
*-----------------------------------------------
END
