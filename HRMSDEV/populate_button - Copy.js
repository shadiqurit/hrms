var vid = $('#P500_ID').val();
//var deptnoValue = document.getElementById('P500_ID').value;

apex.server.process('EMP_DATA_AJ', {
//  x01: null
pageItems: "#P500_ID"
}, {
  dataType: 'json',
  success: function(data) {
    var items = data.items;

    // Get the Interactive Grid region by static ID
    var ig = apex.region("EMPLOYEES").widget().interactiveGrid('getViews', 'grid');
    var model = ig.model;

    // Ensure that ig and model are valid
    if (!model) {
      console.error('Model not found!');
      return;
    }

    // Iterate through each item in the response and add it to the grid
    items.forEach(item => {
      var myNewRecordId = model.insertNewRecord();
      var myNewRecord = model.getRecord(myNewRecordId);

      model.setValue(myNewRecord, 'ENAME', item.ename || 'N/A');
      model.setValue(myNewRecord, 'MGR', item.mgr || 'N/A');
      model.setValue(myNewRecord, 'HIREDATE', new Date(item.hiredate).toLocaleDateString() || 'N/A');
      model.setValue(myNewRecord, 'JOB', item.job || 'N/A');
      model.setValue(myNewRecord, 'SAL', (item.sal || '0').toString());
      model.setValue(myNewRecord, 'COMM', (item.comm !== null ? item.comm : "").toString());
      model.setValue(myNewRecord, 'DEPTNO', (item.deptno || 'N/A').toString());
    });

    // Refresh the entire Interactive Grid
    ig.refresh();
  },
  error: function() {
    console.error('Error fetching data from Application Process');
  }
});
