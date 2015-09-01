// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// mMRFCsampler
NumericVector mMRFCsampler(NumericMatrix Data, int n, int nNodes, NumericVector type_c, NumericVector levels, int nIter, NumericMatrix thresh_m, NumericMatrix graphe, IntegerVector inde);
RcppExport SEXP mgm_mMRFCsampler(SEXP DataSEXP, SEXP nSEXP, SEXP nNodesSEXP, SEXP type_cSEXP, SEXP levelsSEXP, SEXP nIterSEXP, SEXP thresh_mSEXP, SEXP grapheSEXP, SEXP indeSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< NumericMatrix >::type Data(DataSEXP);
    Rcpp::traits::input_parameter< int >::type n(nSEXP);
    Rcpp::traits::input_parameter< int >::type nNodes(nNodesSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type type_c(type_cSEXP);
    Rcpp::traits::input_parameter< NumericVector >::type levels(levelsSEXP);
    Rcpp::traits::input_parameter< int >::type nIter(nIterSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type thresh_m(thresh_mSEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type graphe(grapheSEXP);
    Rcpp::traits::input_parameter< IntegerVector >::type inde(indeSEXP);
    __result = Rcpp::wrap(mMRFCsampler(Data, n, nNodes, type_c, levels, nIter, thresh_m, graphe, inde));
    return __result;
END_RCPP
}