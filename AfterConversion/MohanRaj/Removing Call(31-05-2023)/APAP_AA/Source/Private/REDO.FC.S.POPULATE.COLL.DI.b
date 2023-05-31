* @ValidationCode : MjoxMTQzODIwNTczOkNwMTI1MjoxNjg1NTMwNzEyODU2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:28:32
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
SUBROUTINE REDO.FC.S.POPULATE.COLL.DI
*-----------------------------------------------------------------------------------
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      Conversion Tool    AUTO R22 CODE CONVERSION          VM TO @VM,FM TO @FM
*29-03-2023      MOHANRAJ R         MANUAL R22 CODE CONVERSION         Package name added APAP.AA, CALL method format changed
*-----------------------------------------------------------------------------------
* Developer    : jvalarezoulloa@temenos.com
* Date         : 2012-04-01
* Description  : Laod values fom Collateral Record
* Input/Output:
* -------------
* In  :
*
* Out :
*------------------------------------------------------------------------------------------------------------------
* Revision History:
* -----------------
* Version          Date          Name              Description
* -------          ----          ----              ------------
*
*------------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_EB.TRANS.COMMON
*
    $INSERT I_F.LIMIT
    $INSERT I_F.COLLATERAL.RIGHT
    $INSERT I_F.COLLATERAL
* PACS00297652 - S
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
* PACS00297652 - E
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
    $USING APAP.REDOFCFI
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS

RETURN
*------------------------------------------------------------------------------------------------------------------
* <region name=PROCESS>
PROCESS:
*------------------------------------------------------------------------------------------------------------------

    IF OFS$HOT.FIELD MATCHES 'SEC.NO.STATE.DI...' THEN
        Y.CAMPO.HOTVLD = OFS$HOT.FIELD
        CHANGE "." TO @FM IN Y.CAMPO.HOTVLD ;*AUTO R22 CODE CONVERSION
        YPOSU = DCOUNT(Y.CAMPO.HOTVLD,@FM) ;*AUTO R22 CODE CONVERSION
        Y.I = FIELD(Y.CAMPO.HOTVLD,@FM,YPOSU) ;*AUTO R22 CODE CONVERSION
        IF COMI THEN
            GOSUB NUMERO.GARANTIA
        END
        ELSE
            R.NEW(REDO.FC.COLL.RE.USED.DI)<1,Y.I> = ""
        END
    END
    ELSE
        Y.COUNT = DCOUNT(R.NEW(REDO.FC.TYPE.OF.SEC.DI),@VM) ;*AUTO R22 CODE CONVERSION
        GOSUB CLR.COLL.RIGHT.FLDS
        FOR Y.I = 1 TO Y.COUNT
            Y.SEC.NO = R.NEW(REDO.FC.SEC.NO.STATE.DI)<1,Y.I>
            IF Y.SEC.NO THEN
                GOSUB NUMERO.GARANTIA
            END
        NEXT Y.I

    END

RETURN
* </region>

*------------------------------------------------------------------------------------------------------------------
* <region name=NUMERO.GARANTIA>
NUMERO.GARANTIA:
*------------------------------------------------------------------------------------------------------------------


    CALL F.READ(FN.COLLATERAL,Y.SEC.NO,R.COLLATERAL,F.COLLATERAL,ERR.MSJ)
    IF R.COLLATERAL THEN
        GOSUB POPULATE.RCA
    END ELSE
        AF = REDO.FC.SEC.NO.STATE.DI
        AV=Y.I
        ETEXT = 'EB-FC-DONT-EXITS-COLL'
        CALL STORE.END.ERROR
    END
RETURN
* </region>
*------------------------------------------------------------------------------------------------------------------
POPULATE.RCA:
    R.NEW(REDO.FC.TYPE.OF.SEC.DI)<1,Y.I> = R.COLLATERAL<COLL.COLLATERAL.CODE>
    R.NEW(REDO.FC.SEC.CLASSIFY.DI)<1,Y.I>= R.COLLATERAL<COLL.COLLATERAL.TYPE>
    R.NEW(REDO.FC.SEC.HLD.IDEN.DI)<1,Y.I> = R.COLLATERAL<COLL.LOCAL.REF,WPOSSECH>
    R.NEW(REDO.FC.COLL.CURRENCY.DI)<1,Y.I> = R.COLLATERAL<COLL.CURRENCY>
    R.NEW(REDO.FC.SEC.CREATE.DATE.DI)<1,Y.I>= R.COLLATERAL<COLL.VALUE.DATE>
    R.NEW(REDO.FC.GRANTING.DATE.DI)<1,Y.I> = R.COLLATERAL<COLL.LOCAL.REF,WPOSGTDATA>
    R.NEW(REDO.FC.EXECUTING.DATE.DI)<1,Y.I> = R.COLLATERAL<COLL.LOCAL.REF,WPOSEXEDATE>
    R.NEW(REDO.FC.SEC.VALUE.DI)<1,Y.I>= R.COLLATERAL<COLL.NOMINAL.VALUE>
    R.NEW(REDO.FC.SEC.EXE.VAL.DI)<1,Y.I>= R.COLLATERAL<COLL.EXECUTION.VALUE>
    R.NEW(REDO.FC.GEN.LEDGER.VAL.DI)<1,Y.I>= R.COLLATERAL<COLL.GEN.LEDGER.VALUE>
* PACS00297652 - S
*      R.NEW(REDO.FC.AVAIL.COLL.BAL.DI)<1,Y.I> = R.COLLATERAL<COLL.LOCAL.REF,WPOSAVAILCOL>
    Y.AA.ID = R.COLLATERAL<COLL.LOCAL.REF,WPOSAAID>
    GOSUB GET.AA.CURBAL
    GOSUB GET.AA.AMOUNT
    Y.COL.AVA.AMT = Y.AA.AMOUNT - Y.AA.BAL
    R.NEW(REDO.FC.AVAIL.COLL.BAL.DI)<1,Y.I> = Y.COL.AVA.AMT
* PACS00297652 - E
    R.NEW(REDO.FC.CENT.BANK.VAL.DI)<1,Y.I>= R.COLLATERAL<COLL.CENTRAL.BANK.VALUE>
    R.NEW(REDO.FC.NUM.INST.COLL.DI)<1,Y.I> = R.COLLATERAL<COLL.LOCAL.REF,WPOSAVAMOINS>
    R.NEW(REDO.FC.LOAN.MAX.PERC.DI)<1,Y.I> = R.COLLATERAL<COLL.LOCAL.REF,WPOSMAXPERC>       ;* PORCENTAJE MAXIMO A PRESTAR
    R.NEW(REDO.FC.MAX.LOAN.AMT.DI)<1,Y.I> = R.COLLATERAL<COLL.LOCAL.REF,WPOSMAXAMT>         ;* MONTO MAXIMO A PRESTAR
    R.NEW(REDO.FC.NAME.COLL.OWNER.DI)<1,Y.I> = R.COLLATERAL<COLL.LOCAL.REF,WPOSOWNERDI>     ;* NOMBRE PROPIETARIO DEL INSTRUMENTO
    R.NEW(REDO.FC.MATUR.DATE.DI)<1,Y.I> = R.COLLATERAL<COLL.LOCAL.REF,WPOSINVSDT> ;* Fecha de vencimiento del deposito
    R.NEW(REDO.FC.COLL.RE.USED.DI)<1,Y.I> = "Y"
* Call routine to populate COLLATERAL.RIGHT
    APAP.REDOFCFI.redoFcSPopCollRight(Y.SEC.NO, Y.I);* R22 Manual conversion
RETURN
*------------------------------------------------------------------------------------------------------------------
GET.LOCAL.FIELD:
*------------------------------------------------------------------------------------------------------------------
    WCAMPO = ''
    WCAMPO<1> = "L.COL.SEC.HOLD"
    WCAMPO<2> ="L.COL.GT.DATE"
    WCAMPO<3> ="L.COL.EXE.DATE"
    WCAMPO<4> ="L.COL.VAL.AVA"  ;* "L.COL.AVAIL.COL"
    WCAMPO<5> ="L.COL.NUM.INSTR"
    WCAMPO<6> ="L.COL.LN.MX.PER"          ;* PORCENTAJE MAXIMO A PRESTAR
    WCAMPO<7> ="L.COL.LN.MX.VAL"          ;* MONTO MAXIMO A PRESTAR
    WCAMPO<8> ="L.COL.SE.HLD.NA"          ;* NOMBRE PROPIETARIO DEL INSTRUMENTO
    WCAMPO<9> ="L.COL.INVST.DT" ;* Fecha de vencimiento del deposito
    WCAMPO<10> ="L.AC.LK.COL.ID"          ;* AA ID asociado a la garantia PACS00297652 - S/E

    WCAMPO = CHANGE(WCAMPO,@FM,@VM) ;*AUTO R22 CODE CONVERSION

    TXN.REF.ID.POS=''
    LOC.REF.APPLICATION = 'COLLATERAL'
    LOC.REF.FIELDS = WCAMPO
    LOC.REF.POS = ''

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)


RETURN
*------------------------------------------------------------------------------------------------------------------
INITIALISE:
*------------------------------------------------------------------------------------------------------------------
    YERR          = ''
    Y.SEC.NO      = COMI
    LOOP.CNT      = 1
    MAX.LOOPS     = 1
    PROCESS.GOAHEAD = 1
    P.MESSAGE     = ''
    Y.REDO.FC.POL.ERR = ''
    Y.AA.ID       = ''          ;* PACS00297652 - S/E

    GOSUB GET.LOCAL.FIELD

    WPOSSECH      = LOC.REF.POS<1,1>
    WPOSGTDATA    = LOC.REF.POS<1,2>
    WPOSEXEDATE   = LOC.REF.POS<1,3>
    WPOSAVAILCOL  = LOC.REF.POS<1,4>
    WPOSAVAMOINS  = LOC.REF.POS<1,5>
    WPOSMAXPERC   = LOC.REF.POS<1,6>
    WPOSMAXAMT    = LOC.REF.POS<1,7>
    WPOSOWNERDI   = LOC.REF.POS<1,8>
    WPOSINVSDT    = LOC.REF.POS<1,9>
    WPOSAAID      = LOC.REF.POS<1,10>     ;* PACS00297652 - S/E

    FN.COLLATERAL = "F.COLLATERAL"
    F.COLLATERAL  = ""
    R.COLLATERAL  = ""

* PACS00297652 - S
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    AA.ARR = ''
* PACS00297652 - E
    YPOSU         = ''
RETURN
*------------------------------------------------------------------------------------------------------------------
* <region name=OPENFILES>

OPENFILES:
    CALL OPF(FN.COLLATERAL, F.COLLATERAL)
* PACS00297652 - S
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
* PACS00297652 - E
*
RETURN
* </region>
*------------------------------------------------------------------------------------------------------------------
CLR.COLL.RIGHT.FLDS:
*------------------------------------------------------------------------------------------------------------------
    R.NEW(REDO.FC.ID.COLLATERL.RIGHT)=''
    R.NEW(REDO.FC.COLL.RIGHT.CODE)=''
    R.NEW(REDO.FC.LIMIT.REFERENCE)=''
    R.NEW(REDO.FC.VALIDITY.DATE)=''
    R.NEW(REDO.FC.SEC.HOLD.IDENTIF)=''



RETURN

** <region name= GET.AA.CURBAL>
GET.AA.CURBAL:
***
* Getting current AA Balance value
    Y.AA.BAL = ''
    GOSUB GET.AA.PRODUCT
    Y.AA.BAL = AA.ARR
    APAP.AA.redoSFcAaBal(Y.AA.ID, Y.AA.BAL);* R22 Manual conversion
    Y.AA.BAL = ABS(Y.AA.BAL)
    IF Y.AA.BAL EQ 'NULO' THEN
        Y.AA.BAL = 0
    END
*
RETURN
*** </region>

** <region name= GET.AA.CURBAL>
GET.AA.AMOUNT:
***
* Getting current AA Balance value
    Y.AA.AMOUNT = ''
    Y.AA.AMOUNT = AA.ARR
    APAP.AA.redoSFcAaAmount(Y.AA.ID, Y.AA.AMOUNT);* R22 Manual conversion
    Y.AA.AMOUNT = ABS(Y.AA.AMOUNT)
    IF Y.AA.AMOUNT EQ 'NULO' THEN
        Y.AA.AMOUNT = 0
    END
*
RETURN
*
*** </region>

** <region name= GET.AA.PRODUCT>
GET.AA.PRODUCT:
***
    Y.ERR = ''
    CALL F.READ(FN.AA.ARRANGEMENT, Y.AA.ID, AA.ARR, F.AA.ARRANGEMENT, Y.ERR)
*
RETURN
** </region>

END
