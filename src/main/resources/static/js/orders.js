function addRow() {
  const tbody = document.getElementById('itemsBody');
  const row = document.createElement('tr');
  row.innerHTML = `
    <td>
      <select name="vegetableIds" required>
        ${document.querySelector('#itemsBody select[name="vegetableIds"]').innerHTML}
      </select>
    </td>
    <td>
      <input name="quantities" type="number" min="1" value="1" required />
    </td>
    <td>
      <button type="button" class="link danger" onclick="removeRow(this)">Remove</button>
    </td>
  `;
  // Reset the first option to placeholder
  const sel = row.querySelector('select[name="vegetableIds"]');
  if (sel.options.length > 0) sel.selectedIndex = 0;
  tbody.appendChild(row);
}

function removeRow(btn) {
  const tr = btn.closest('tr');
  const tbody = tr.parentElement;
  if (tbody.children.length > 1) {
    tbody.removeChild(tr);
  } else {
    // Clear values instead of removing the last row
    tr.querySelector('select[name="vegetableIds"]').selectedIndex = 0;
    tr.querySelector('input[name="quantities"]').value = 1;
  }
}