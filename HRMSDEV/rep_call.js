//fixed report Calling
var v_server = $('#P_REP_SERVER').val();
var v_format = $('#P_FORMAT').val();
var v_login = $('#P_LOGON_USER').val();
var v_path = $('#P_REP_PATH').val();
var v_com = $('#G_COMPANY_ID').val();
//Parameter Value pass
var v_fdate = $('#P102_FORM_DATE').val();
var v_tdate = $('#P102_TO_DATE').val();
var v_unit = $('#P102_UNIT').val();
var v_sale_loc = $('#P102_SALES_LOC').val();
var v_sale_ex = $('#P102_SALES_EX').val();
var v_purchase = $('#P102_PUR_LOC').val();
var v_purchase_imp = $('#P102_PUR_EX').val();
var v_payment = $('#P102_PAYMENT').val(); //P_PT_ID
// $('#P102_RG').on('change', function () {
//   $val = apex.item('P102_RG').getValue();
// });
try {
  $val = apex.item('P102_RG').getValue();
} catch (error) {
  console.error('An error occurred:', error);
}
//SUB_FROM_KA_SALES.RDF&P_FROM_DATE&p_TYPE
if ($val == 6) {
  window.open(v_server + v_format + v_login + v_path + '\\Reports\\SUB_FROM_KA_SALES.RDF&P_FROM_DATE=' + v_fdate + v_path +
    '\\Reports\\SUB_FROM_KA_SALES.RDF&P_TO_DATE=' + v_tdate + v_path + '\\Reports\\SUB_FROM_KA_SALES.RDF&p_TYPE=' + v_sale_loc + v_path +
    '\\Reports\\SUB_FROM_KA_SALES.RDF&G_COMPANY_ID=' + v_com);
  //SUB_FROM_KA_SALES_Export.RDF&p_TYPE=E
} else if ($val == 7) {
  window.open(v_server + v_format + v_login + v_path + '\\Reports\\SUB_FROM_KA_SALES.RDF&P_FROM_DATE=' + v_fdate + v_path +
    '\\Reports\\SUB_FROM_KA_SALES.RDF&P_TO_DATE=' + v_tdate + v_path + '\\Reports\\SUB_FROM_KA_SALES.RDF&p_TYPE=' + v_sale_ex + v_path +
    '\\Reports\\SUB_FROM_KA_SALES.RDF&G_COMPANY_ID=' + v_com);
  //\SUB_FROM_KA_purchase.RDF&p_TYPE=SL
} else if ($val == 91) {
  window.open(v_server + v_format + v_login + v_path + '\\Reports\\SUB_FROM_KA_purchase.RDF&P_FROM_DATE=' + v_fdate + v_path +
    '\\Reports\\SUB_FROM_KA_purchase.RDF&P_TO_DATE=' + v_tdate + v_path + '\\Reports\\SUB_FROM_KA_purchase.RDF&p_TYPE=' + v_purchase + v_path +
    '\\Reports\\SUB_FROM_KA_purchase.RDF&G_COMPANY_ID=' + v_com);
  // //SUB_FROM_KA_purchase_New.RDF&p_TYPE=SI
} else if ($val == 92) {
  window.open(v_server + v_format + v_login + v_path + '\\Reports\\SUB_FROM_KA_purchase.RDF&P_FROM_DATE=' + v_fdate + v_path +
    '\\Reports\\SUB_FROM_KA_purchase.RDF&P_TO_DATE=' + v_tdate + v_path + '\\Reports\\SUB_FROM_KA_purchase.RDF&p_TYPE=' + v_purchase_imp + v_path +
    '\\Reports\\SUB_FROM_KA_purchase.RDF&G_COMPANY_ID=' + v_com);
} else if ($val == 13) {
  window.open(v_server + v_format + v_login + v_path + '\\Reports\\SUB_FROM_cha.RDF&P_FROM_DATE=' + v_fdate + v_path +
    '\\Reports\\SUB_FROM_cha.RDF&P_TO_DATE=' + v_tdate + v_path + '\\Reports\\SUB_FROM_cha.RDF&G_COMPANY_ID=' + v_com);
  //SUB_FROM_cha.rdf
} else if ($val == 11) {
  window.open(v_server + v_format + v_login + v_path + '\\Reports\\SUB_FROM_GhA_vds.RDF&P_FROM_DATE=' + v_fdate + v_path +
    '\\Reports\\SUB_FROM_GhA_vds.RDF&P_TO_DATE=' + v_tdate + v_path + '\\Reports\\SUB_FROM_GhA_vds.RDF&G_COMPANY_ID=' + v_com);
  //SUB_FROM_cha.rdf
} else if ($val == 14) {
  window.open(v_server + v_format + v_login + v_path + '\\Reports\\SUB_CHHA.RDF&P_FROM_DATE=' + v_fdate + v_path + '\\Reports\\SUB_CHHA.RDF&P_TO_DATE=' +
    v_tdate + v_path + '\\Reports\\SUB_CHHA.RDF&G_COMPANY_ID=' + v_com + v_path + '\\Reports\\SUB_CHHA.RDF&P_PT_ID=' + v_payment);
} else if ($val > 0) {
  swal("Sorry!!", " Report Under Development!!", "info", {
    dangerMode: false
  });
} else {
  swal("Sorry!!", " Report not selected!!", "error", {
    dangerMode: true
  });
}