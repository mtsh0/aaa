shared_examples 'test autonumeric-rails version' do
  context 'Through form helper' do
    let(:url) { 'static_fields' }
    it_behaves_like 'all autonumeric-rails tests'
  end

  context 'Javascript manually created fields' do
    let(:url) { 'javascript_fields' }
    it_behaves_like 'all autonumeric-rails tests'
  end

  context 'AJAX request created fields' do
    let(:url) { 'ajax_fields' }
    it_behaves_like 'all autonumeric-rails tests'
  end
end


shared_examples 'all autonumeric-rails tests' do
  context 'Without DB' do
    let(:record_id) { '' }

    it 'Input tag' do
      assert_selector(%q{input#record_field1[name='record[field1]'][data-autonumeric='true']})
      assert_selector("input#record_field2[name='record[field2]'][data-autonumeric='#{expected_params}']")
    end

    it 'Hidden tags' do
      assert_selector(%q{input#record_field1_val[name='record[field1]'][type='hidden']})
      assert_selector(%q{input#record_field2_val[name='record[field2]'][type='hidden']})
    end

    it 'Hidden tag is located after Input tag' do
      expect(find(:xpath, %q{.//*[@id='record_field1']/following-sibling::*[1]})['id']).to eq('record_field1_val')
      expect(find(:xpath, %q{.//*[@id='record_field2']/following-sibling::*[1]})['id']).to eq('record_field2_val')
    end

    it 'Set empty default values' do
      expect(find('#record_field1').value).to eq('')
      expect(find('#record_field1_val').value).to eq('')

      expect(find('#record_field2').value).to eq('')
      expect(find('#record_field2_val').value).to eq('')
    end

    it 'Typing value updates hidden field value' do
      find('#record_field1').set '12345'
      find('#record_field2').set '54321.987'

      expect(find('#record_field1').value).to eq('12,345.00')
      expect(find('#record_field1_val').value).to eq('12345')

      expect(find('#record_field2').value).to eq('USD 54,321.9')
      expect(find('#record_field2_val').value).to eq('54321.9')
    end

    it 'Creates record without values' do
      click_button 'Go'

      from_db = Record.last
      expect(from_db.field1).to eq(nil)
      expect(from_db.field2).to eq(nil)
    end

    it 'Creates record with values' do
      find('#record_field1').set '122333'
      find('#record_field2').set '4444.5'
      click_button 'Go'

      from_db = Record.last
      expect(from_db.field1).to eq(122333)
      expect(from_db.field2).to eq(4444.5)
    end
  end

  context 'With DB record' do
    let(:record) { Record.create field1: 112233, field2: 445566.7 }
    let(:record_id) { "/#{record.id}" }

    it 'Loads record and set values' do
      expect(find('#record_field1').value).to eq('112,233.00')

      if test_version == '1'
        expect(find('#record_field1_val').value).to eq('112233')
      elsif test_version == '2'
        expect(find('#record_field1_val').value).to eq('112233.00') # Default output changed with v2
      else
        raise "Not handled version #{test_version}. Please add test case"
      end


      expect(find('#record_field2').value).to eq('USD 445,566.7')
      expect(find('#record_field2_val').value).to eq('445566.7')
    end

    it 'Without modifying values' do
      click_button 'Go'

      from_db = Record.find record.id
      expect(from_db.field1).to eq(112233)
      expect(from_db.field2).to eq(445566.7)
    end

    it 'Updates record' do
      find('#record_field1').set '332211'
      find('#record_field2').set '776655.4'
      click_button 'Go'

      from_db = Record.find record.id
      expect(from_db.field1).to eq(332211)
      expect(from_db.field2).to eq(776655.4)
    end
  end

  context 'deleting autonumeric object' do
    let(:record_id) { '' }

    before { execute_script 'AutonumericRails.delete_autonumeric_object($("#record_field1"));' }

    it 'Input tag' do
      assert_selector(%q{input#record_field1[name='record[field1]']:not([data-autonumeric])})
      assert_selector("input#record_field2[name='record[field2]'][data-autonumeric='#{expected_params}']")
    end

    it 'Hidden tags' do
      assert_no_selector('input#record_field1_val')
      assert_selector(%q{input#record_field2_val[name='record[field2]'][type='hidden']})
    end

    it 'Typing value after delete_autonumeric_object' do

      find('#record_field1').set '12345'
      find('#record_field2').set '54321.987'

      expect(find('#record_field1').value).to eq('12345')
      expect(all('#record_field1_val').count).to eq(0)

      expect(find('#record_field2').value).to eq('USD 54,321.9')
      expect(find('#record_field2_val').value).to eq('54321.9')
    end
  end
end