* @ValidationCode : MjoxOTU3MTk0MjcxOkNwMTI1MjoxNjgxMTE0NjU2MzgzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 13:47:36
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
SUBROUTINE REDO.S.FETCH.ADDRESS(RES)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Prabhu N
*Program   Name    :REDO.S.FETCH.ADDRESS
*-------------------------------------------------------------------------------

*DESCRIPTION       :This subroutine is used to get the value from DE.ADDRESS and will update the deal slip DCARD.RECEIPT
*
* ----------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* Revision History
*-------------------------
*    Date             Who               Reference       Description
* 23-MAY-2011        Prabhu.N           PACS00060198    Initial creation
* 01 JUL 2011        KAVITHA            PACS00062260    ISSUE FIX
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     F.READ TO CACHE.READ,VM TO @VM,++ TO +=1
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*----------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DE.ADDRESS
    $INSERT I_F.COUNTRY
    $INSERT I_F.COMPANY
    $INSERT I_F.LATAM.CARD.ORDER


    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN
*-----*
INIT:
*-----*



*PACS00062260 -S

*    Y.CUST.ID=RES
    Y.CUST.ID = R.NEW(CARD.IS.CUSTOMER.NO)<1,1>

*PACS00062260 -E

    RES=''
    LOC.REF.APPLICATION="DE.ADDRESS"
    LOC.REF.FIELDS="L.DA.NO.DIR":@VM:"L.CU.URB.ENS.RE":@VM:"L.CU.RES.SECTOR":@VM:"L.DA.PAIS":@VM:"L.DA.APT.POSTAL"
    LOC.REF.POS=''
RETURN
*---------*
OPEN.FILES:
*----------*
    FN.DE.ADD = 'F.DE.ADDRESS'
    F.DE.ADD = ''
    CALL OPF(FN.DE.ADD,F.DE.ADD)

    FN.CUST='F.CUSTOMER'
    F.CUST=''
    CALL OPF(FN.CUST,F.CUST)

    FN.COUNTRY = 'F.COUNTRY'
    F.COUNTRY = ''
    CALL OPF(FN.COUNTRY,F.COUNTRY)

RETURN
*-------*
PROCESS:
*-------*
    RES.TEMP = ''

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    Y.L.DA.NO.DIR.POS=LOC.REF.POS<1,1>
    Y.L.CU.URB.ENS.RE.POS=LOC.REF.POS<1,2>
    Y.L.CU.RES.SECTOR.POS=LOC.REF.POS<1,3>
    Y.L.DA.PAIS.POS=LOC.REF.POS<1,4>
    Y.L.DA.APT.POSTAL.POS=LOC.REF.POS<1,5>
    FRAME.ID = R.COMPANY(EB.COM.CUSTOMER.COMPANY):'.C-':Y.CUST.ID:'.PRINT.1'
    CALL F.READ(FN.DE.ADD,FRAME.ID,R.DE.ADDRESS,F.DE.ADD,DE.ADD.ERR1)
    Y.STREET.ADDR     =R.DE.ADDRESS<DE.ADD.STREET.ADDRESS>
    Y.L.DA.NO.DIR     =R.DE.ADDRESS<DE.ADD.LOCAL.REF,Y.L.DA.NO.DIR.POS>
    Y.L.CU.URB.ENS.RE =R.DE.ADDRESS<DE.ADD.LOCAL.REF,Y.L.CU.URB.ENS.RE.POS>
    Y.L.CU.RES.SECTOR =R.DE.ADDRESS<DE.ADD.LOCAL.REF,Y.L.CU.RES.SECTOR.POS>
    Y.COUNTRY         =R.DE.ADDRESS<DE.ADD.COUNTRY>
    Y.TOWN.COUNTRY   =R.DE.ADDRESS<DE.ADD.TOWN.COUNTY>
    Y.L.DA.PAIS       =R.DE.ADDRESS<DE.ADD.LOCAL.REF,Y.L.DA.PAIS.POS>

    CALL CACHE.READ(FN.COUNTRY, Y.L.DA.PAIS, R.COUNTRY, COUNT.ERR) ;*R22 Auto code conversion
    IF R.COUNTRY THEN
        Y.L.DA.PAIS = R.COUNTRY<EB.COU.SHORT.NAME>
    END

    Y.L.DA.APT.POSTAL =R.DE.ADDRESS<DE.ADD.LOCAL.REF,Y.L.DA.APT.POSTAL.POS>
    Y.INIT.STR =STR(" ",34)
    RES.TEMP<1>=Y.STREET.ADDR : "  ": Y.L.DA.NO.DIR
    RES.TEMP<1>=TRIM(RES.TEMP<1>)
    RES.TEMP<2>=Y.L.CU.URB.ENS.RE : "  " : Y.L.CU.RES.SECTOR
    RES.TEMP<2>=TRIM(RES.TEMP<2>)
    RES.TEMP<2>=Y.INIT.STR : RES.TEMP<2>
    RES.TEMP<3>=Y.COUNTRY : "  " : Y.TOWN.COUNTRY
    RES.TEMP<3>=TRIM(RES.TEMP<3>)
    RES.TEMP<3>=Y.INIT.STR : RES.TEMP<3>
    RES.TEMP<4>=Y.L.DA.PAIS
    RES.TEMP<4>=Y.INIT.STR : RES.TEMP<4>
    RES.TEMP<5>=Y.L.DA.APT.POSTAL
    RES.TEMP<5>=Y.INIT.STR:RES.TEMP<5>
    Y.CNT=1
    Y.FINAL.CNT=1
    LOOP
    WHILE Y.CNT LE 5
        IF RES.TEMP<Y.CNT> THEN
            RES<Y.FINAL.CNT>=RES.TEMP<Y.CNT>
            Y.FINAL.CNT += 1 ;*R22 Auto code conversion
        END
        Y.CNT += 1 ;*R22 Auto code conversion
    REPEAT
RETURN
END
