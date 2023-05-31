$PACKAGE APAP.AA ;*MANUAL R22 CODE CONVERSION
SUBROUTINE REDO.V.VAL.INT.ARR
     
*-----------------------------------------------------------------------------------
* Modification History:
* DATE                 WHO                  REFERENCE                    DESCRIPTION
* 29/03/2023         SURESH      MANUAL R22 CODE CONVERSION        Package Name added APAP.AA
* 29/03/2023         Conversion Tool      AUTO R22 CODE CONVERSION          VM TO @VM,SM TO @SM,CALL F.READ TO CALL CACHE.READ
*-----------------------------------------------------------------------------------
*----------------------------------------------------------------------
*Company Name: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Program Name: REDO.V.VAL.INT.ARR
*------------------------------------------------------------------------------------------------------------------------------------------
*Description:
* This validation routine will check payment method is "Direct Debit" and then allow to input the account this loan customer
*If not override and error will be thrown
*----------------------------------------------------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* DATE WHO REFERENCE DESCRIPTION
* 6-06-2010 PREETHI MD ODR-2009-10-0326 N.3 INITIAL CREATION
*
* 08-03-2011 Ravikiran APAP001-PACS00035728 Loop each tier and add it to Interest rate arrears
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.BASIC.INTEREST
    $INSERT I_AA.LOCAL.COMMON


    GOSUB INIT
    GOSUB PROCESS
RETURN
*---------------------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------------------
    Y.CURRENCY=c_aalocArrCurrency
    FN.INTEREST="F.AA.INTEREST"
    F.INTEREST=""

    FN.BASICINTEREST="F.BASIC.INTEREST"
    F.BASICINTEREST=""
    R.BASICINTEREST=""

RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------------

    CALL GET.LOC.REF("AA.PRD.DES.INTEREST","L.AA.INT.RT.AR",INTARR.POS)

    Y.FIXED.COUNT=DCOUNT(R.NEW(AA.INT.FIXED.RATE),@VM) ;*AUTO R22 CODE CONVERSION
    Y.FIXEDRATE=R.NEW(AA.INT.FIXED.RATE)
    Y.PERIODICRATE=R.NEW(AA.INT.PERIODIC.RATE)
    Y.FLOATINGINDEX=R.NEW(AA.INT.FLOATING.INDEX)
    Y.MARGINRATE=R.NEW(AA.INT.MARGIN.RATE)
    Y.EFFECTIVERATE=R.NEW(AA.INT.EFFECTIVE.RATE)

    Y.INITIAL=1

    FOR INT.RATE.COUNT=1 TO Y.FIXED.COUNT

*PACS00035728 - commented the code done
*REMOVE Y.FIXED1 FROM Y.FIXEDRATE SETTING Y.POS1      ;*AUTO R22 CODE CONVERSION
*REMOVE Y.PERIODIC1 FROM Y.PERIODICRATE SETTING Y.POS2
*REMOVE Y.FLOATING1 FROM Y.FLOATINGINDEX SETTING Y.POS3

        IF Y.FIXEDRATE OR Y.PERIODICRATE THEN
*R.NEW(AA.INT.LOCAL.REF)<1,INTARR.POS>=Y.EFFECTIVERATE<1,INT.RATE.COUNT> ;*AUTO R22 CODE CONVERSION

            R.NEW(AA.INT.LOCAL.REF)<1,INTARR.POS>=SUM(Y.EFFECTIVERATE) ;*PACS00035728 - Adds all the Interest MV sets to Interest rate arrears

        END ELSE
            IF Y.FLOATINGINDEX THEN
                Y.MARGIN.COUNT=DCOUNT(Y.MARGINRATE,@SM) ;*AUTO R22 CODE CONVERSION
                REMOVE Y.MARGIN FROM Y.MARGINRATE SETTING POS1

                Y.BASICINTEREST.ID=Y.FLOATINGINDEX:Y.CURRENCY

                SEL.CMD="SELECT ":FN.BASICINTEREST:" BY-DSND @ID LIKE ":Y.BASICINTEREST.ID:"..."
                CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,ERR)
                Y.BI.ID=SEL.LIST<1>
                CALL OPF(FN.BASICINTEREST,F.BASICINTEREST)
                CALL CACHE.READ(FN.BASICINTEREST, Y.BI.ID, R.BASICINTEREST, Y.ERR) ;*AUTO R22 CODE CONVERSION
                Y.INTERESTRATE=R.BASICINTEREST<EB.BIN.INTEREST.RATE>
                R.NEW(AA.INT.LOCAL.REF)<1,INTARR.POS>=Y.INTERESTRATE + Y.MARGIN
            END
        END
    NEXT INT.RATE.COUNT
RETURN
END
