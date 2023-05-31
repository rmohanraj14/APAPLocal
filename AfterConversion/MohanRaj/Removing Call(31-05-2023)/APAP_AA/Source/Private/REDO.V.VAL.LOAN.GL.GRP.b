$PACKAGE APAP.AA ;*MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.V.VAL.LOAN.GL.GRP
    
*-----------------------------------------------------------------------------------
* Modification History:
* DATE                 WHO                  REFERENCE                    DESCRIPTION
* 29/03/2023         SURESH      MANUAL R22 CODE CONVERSION        Package Name added APAP.AA
* 29/03/2023         Conversion Tool      AUTO R22 CODE CONVERSION        CALL F.READ TO  CALL CACHE.READ
*-----------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*Company Name: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Program Name: REDO.V.VAL.LOAN.GL.GRP
*---------------------------------------------------------------------------------
* DESCRIPTION:
*---------------------------------------------------------------------------------
*            This routine is a validation routine to populate the value from field
* PRODUCT.GROUP in AA.PRODUCT to the local field L.AA.LOAN.GL.GRP and
* attached to the version AA.ARRANGEMENT.ACTIVITY,AA.NEW
*----------------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE         DESCRIPTION
* 26-06-2010      SUJITHA.S   ODR-2009-10-0326 N.3  INITIAL CREATION
*
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PRODUCT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_AA.LOCAL.COMMON

    GOSUB INIT
    GOSUB OPEN
    GOSUB PROCESS
RETURN

*------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------

    FN.AA.PRODUCT="F.AA.PRODUCT"
    F.AA.PRODUCT=''
    Y.PRODUCTID=R.NEW(AA.ARR.ACT.PRODUCT)
RETURN

*-------------------------------------------------------------------------------
OPEN:
*-------------------------------------------------------------------------------

    CALL OPF(FN.AA.PRODUCT,F.AA.PRODUCT)
    CALL CACHE.READ(FN.AA.PRODUCT, Y.PRODUCTID, R.AA.PRODUCT, Y.ERR) ;*AUTO R22 CODE CONVERSION
*-------------------------------------------------------------------------------
PROCESS:
*-------------------------------------------------------------------------------

    COMI=R.AA.PRODUCT<AA.PDT.PRODUCT.GROUP>

RETURN
END
