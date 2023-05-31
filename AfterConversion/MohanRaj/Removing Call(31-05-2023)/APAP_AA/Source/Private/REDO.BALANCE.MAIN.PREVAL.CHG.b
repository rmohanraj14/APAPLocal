* @ValidationCode : MjoxMjAxNjQ3NjU3OkNwMTI1MjoxNjgzNjk4NDI2MzUzOklUU1M6LTE6LTE6MzU6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 35
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.BALANCE.MAIN.PREVAL.CHG
   
* Description: This is a Record-Routine for the named Activity CHQ.RETURN.CHG to trigger LENDING-ADJUST.BILL-BALANCE.MAINTENANCE
* to check the passed bill ID in Local field is available in Balance maintenance property and adjust accordingly.
*
*------------------------------------------------------------------------
* Input Argument : NA
* Out Argument   : NA
* Deals With     : ACTIVITY.API
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                          DESCRIPTION
*  16-01-2012     S.MARIMUTHU            PACS00170057                      Initial Draft
* 29-MAR-2023      Conversion Tool                R22 Auto Conversion  - VM to @VM
* 29-MAR-2023      Harsha                R22 Manual Conversion
*                                       Added the Insert file I_AA.LOCAL.COMMON
*                                       c_aalocPropertyId in place of AA$PROPERTY.ID
*                                       c_aalocArrProductId in place of AA$ARR.PRODUCT.ID
*
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
*insert file added I_AA.LOCAL.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.PRODUCT
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.BALANCE.MAINTENANCE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.H.AA.DIS.CHG


    IF V$FUNCTION EQ 'I' THEN   ;* Since its a record so c_aalocActivityStatus variable will not be set.
* This part gets the Balance part.
        ARR.ID = AA$ARR.ID
        ACCOUNT.ID = AA$LINKED.ACCOUNT
        PROPERTY = ''
        RET.ERROR = ''
        BALANCE.TYPE = ''
        BALANCE.MAINTENANCE.REC = ''
        PROCESS.TYPE='GET.BILL'
        CALL AA.PROCESS.BALANCE.MAINTENANCE(PROCESS.TYPE, ACCOUNT.ID, BALANCE.MAINTENANCE.REC, PROPERTY, BALANCE.TYPE, RET.ERROR)
        Y.BALANCE.MAIN.BILLS = BALANCE.MAINTENANCE.REC<AA.BM.BILL.REF>
        GOSUB PROCESS
    END

RETURN
*------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------
* Main process begins here.

    GOSUB GET.LOCAL.REF         ;* To get the local ref field.
    GOSUB CHARGE.PROPERTY.NAME  ;* To get the charge property name.
    GOSUB CHECK.BILLS ;* To check the bill is available in Balance maintenance property record

RETURN
*------------------------------------------------------------------------
GET.LOCAL.REF:
*------------------------------------------------------------------------
* To get the local ref field.

    LOC.REF.APPLICATION="AA.PRD.DES.BALANCE.MAINTENANCE"
    LOC.REF.FIELDS='L.BILL.REF':@VM:'L.BILL.AMOUNT'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.BILL.REF    = LOC.REF.POS<1,1>
    POS.L.BILL.AMOUNT = LOC.REF.POS<1,2>

    FIELD.1 = 'LOCAL.REF:':POS.L.BILL.REF:':1'
    FIELD.2 = 'LOCAL.REF:':POS.L.BILL.AMOUNT:':1'

    FN.AA.PRODUCT = 'F.AA.PRODUCT'
    F.AA.PRODUCT = ''
    CALL OPF(FN.AA.PRODUCT,F.AA.PRODUCT)

    FN.REDO.H.AA.DIS.CHG = 'F.REDO.H.AA.DIS.CHG'
    F.REDO.H.AA.DIS.CHG = ''

RETURN
*------------------------------------------------------------------------
CHARGE.PROPERTY.NAME:
*------------------------------------------------------------------------
* To get the charge property name.
*Y.PRODUCT.ID = AA$ARR.PRODUCT.ID
*** R22 manual conversion ***
    Y.PRODUCT.ID = c_aalocArrProductId      ;* Product ID
    CALL CACHE.READ(FN.AA.PRODUCT, Y.PRODUCT.ID, R.PRODUCT, PROD.ERR)
    Y.PRODUCT.GROUP.ID = R.PRODUCT<AA.PDT.PRODUCT.GROUP>      ;* Product Group ID
    CALL CACHE.READ(FN.REDO.H.AA.DIS.CHG,'SYSTEM',R.REDO.H.AA.DIS.CHG,CHG.ERR)

    IF R.REDO.H.AA.DIS.CHG THEN
        Y.CHQ.PROPERTY        = R.REDO.H.AA.DIS.CHG<REDO.DIS.CHG.RET.CHQ.CHARGE>    ;* Cheque Charge Property
    END ELSE
        RETURN
    END

RETURN
*------------------------------------------------------------------------
CHECK.BILLS:
*------------------------------------------------------------------------
* To check the bill is available in Balance maintenance property record.

    Y.BILL.ADJUST = ''
**LOCATE AA$PROPERTY.ID IN AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.PROPERTY,1> SETTING POS.PROPER THEN
*** R22 manual conversion ***
    LOCATE c_aalocPropertyId IN AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.PROPERTY,1> SETTING POS.PROPER THEN
        LOCATE FIELD.1 IN AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.FIELD.NAME,POS.PROPER,1> SETTING FLD.POS THEN
            Y.BILL.IDS = AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.FIELD.VALUE,POS.PROPER,FLD.POS>
        END
        LOCATE FIELD.2 IN AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.FIELD.NAME,POS.PROPER,1> SETTING FLD.POS1 THEN
            Y.BILL.AMOUNTS =  AA$R.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.FIELD.VALUE,POS.PROPER,FLD.POS1>
        END

    END

    R.NEW(AA.BM.NEW.PROP.AMT) = ''
    R.NEW(AA.BM.NEW.BAL.AMT) = ''
    R.NEW(AA.BM.LOCAL.REF)<1,POS.L.BILL.REF>    = Y.BILL.IDS  ;* Even though when we pass value for local field, its not updated in AA.ARR files.
    R.NEW(AA.BM.LOCAL.REF)<1,POS.L.BILL.AMOUNT> = Y.BILL.AMOUNTS        ;* Even though when we pass value for local field, its not updated in AA.ARR files.

    Y.VAR1 = 1
    Y.BILLS.CNT = DCOUNT(Y.BILL.IDS,@VM)
    LOOP
    WHILE Y.VAR1 LE Y.BILLS.CNT
        Y.BILL.ID = Y.BILL.IDS<Y.VAR1>
        GOSUB UPDATE.AMOUNT


        Y.VAR1 += 1   ;*R22 Auto Conversion
    REPEAT

    IF Y.BILL.ADJUST NE 'YES' THEN
        IF Y.BALANCE.MAIN.BILLS THEN
            R.NEW(AA.BM.NEW.PROP.AMT)<1,1,1> = ABS(BALANCE.MAINTENANCE.REC<AA.BM.OS.PROP.AMT,1,1>)        ;* If suppose the aged bill has been repaid and some other bill is in due then we need to assign the original property amount as the original one.
        END
    END

RETURN

*-------------------------------------------
UPDATE.AMOUNT:
*-------------------------------------------
    Y.BILL.REF.CNT = DCOUNT(BALANCE.MAINTENANCE.REC<AA.BM.BILL.REF>,@VM)

    Y.VAR2 = 1
    LOOP
    WHILE Y.VAR2 LE Y.BILL.REF.CNT
        IF Y.BILL.ID EQ BALANCE.MAINTENANCE.REC<AA.BM.BILL.REF,Y.VAR2> THEN
            LOCATE Y.CHQ.PROPERTY IN  BALANCE.MAINTENANCE.REC<AA.BM.PROPERTY,Y.VAR2,1> SETTING PROP.POS THEN
*R.NEW(AA.BM.NEW.PROP.AMT)<1,Y.VAR2,PROP.POS> = Y.BILL.AMOUNTS<Y.VAR1>
                GOSUB GET.BILL.DETAILS
                R.NEW(AA.BM.ADJ.PROP.AMT)<1,Y.VAR2,PROP.POS> = "-":Y.BILL.AMOUNTS<Y.VAR1>
*R.NEW(AA.BM.DEL.BILL.AMT)<1,Y.VAR2>          = Y.BILL.AMOUNTS<Y.VAR1> + Y.OS.TOTAL.AMOUNT     ;* Updated for Bill status issue.
                Y.BILL.ADJUST = 'YES'
                Y.VAR2 = Y.BILL.REF.CNT+1
            END
        END
        Y.VAR2 += 1
    REPEAT
RETURN
*-------------------------------------------
GET.BILL.DETAILS:
*-------------------------------------------

    ARRANGEMENT.ID    = AA$ARR.ID
    BILL.REFERENCE    = Y.BILL.ID
    BILL.DETAILS      = ''
    Y.OS.TOTAL.AMOUNT = ''
    CALL AA.GET.BILL.DETAILS(ARRANGEMENT.ID, BILL.REFERENCE, BILL.DETAILS, RET.ERROR)
    Y.OS.TOTAL.AMOUNT = BILL.DETAILS<AA.BD.OS.TOTAL.AMOUNT>

RETURN

END
