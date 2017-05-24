procedure InitializeComponent;
    begin
        var resources: System.ComponentModel.ComponentResourceManager := new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
        self.dataGridView1 := new System.Windows.Forms.DataGridView();
        self.richTextBox1 := new System.Windows.Forms.RichTextBox();
        self.button1 := new System.Windows.Forms.Button();
        self.textBox1 := new System.Windows.Forms.TextBox();
        (System.ComponentModel.ISupportInitialize(self.dataGridView1)).BeginInit();
        self.SuspendLayout();
        // 
        // dataGridView1
        // 
        self.dataGridView1.AutoSizeColumnsMode := System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
        self.dataGridView1.ColumnHeadersHeightSizeMode := System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
        self.dataGridView1.Dock := System.Windows.Forms.DockStyle.Top;
        self.dataGridView1.Location := new System.Drawing.Point(0, 0);
        self.dataGridView1.Name := 'dataGridView1';
        self.dataGridView1.RowHeadersVisible := false;
        self.dataGridView1.Size := new System.Drawing.Size(334, 179);
        self.dataGridView1.TabIndex := 0;
        self.dataGridView1.DataError += dataGridView1_DataError;
        // 
        // richTextBox1
        // 
        self.richTextBox1.Dock := System.Windows.Forms.DockStyle.Fill;
        self.richTextBox1.Location := new System.Drawing.Point(0, 179);
        self.richTextBox1.Name := 'richTextBox1';
        self.richTextBox1.Size := new System.Drawing.Size(334, 132);
        self.richTextBox1.TabIndex := 1;
        self.richTextBox1.Text := '2 + 2 ^ (1 and 0 - 2 * not (50 = 10)) * Перем';
        // 
        // button1
        // 
        self.button1.Dock := System.Windows.Forms.DockStyle.Bottom;
        self.button1.Location := new System.Drawing.Point(0, 288);
        self.button1.Name := 'button1';
        self.button1.Size := new System.Drawing.Size(334, 23);
        self.button1.TabIndex := 2;
        self.button1.Text := 'Вычислить';
        self.button1.UseVisualStyleBackColor := true;
        self.button1.Click += button1_Click;
        // 
        // textBox1
        // 
        self.textBox1.Dock := System.Windows.Forms.DockStyle.Bottom;
        self.textBox1.Location := new System.Drawing.Point(0, 268);
        self.textBox1.Name := 'textBox1';
        self.textBox1.ReadOnly := true;
        self.textBox1.Size := new System.Drawing.Size(334, 20);
        self.textBox1.TabIndex := 3;
        // 
        // MainForm
        // 
        self.ClientSize := new System.Drawing.Size(334, 311);
        self.Controls.Add(self.textBox1);
        self.Controls.Add(self.button1);
        self.Controls.Add(self.richTextBox1);
        self.Controls.Add(self.dataGridView1);
        self.Icon := (System.Drawing.Icon(resources.GetObject('$this.Icon')));
        self.MinimumSize := new System.Drawing.Size(350, 350);
        self.Name := 'MainForm';
        self.Text := 'Вычислить выражение';
        self.Load += MainForm_Load;
        (System.ComponentModel.ISupportInitialize(self.dataGridView1)).EndInit();
        self.ResumeLayout(false);
        self.PerformLayout();
    end;
