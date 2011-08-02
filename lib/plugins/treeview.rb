class Shoes
  class App
    def tree_view titles, tables
      @tree_view_methods = titles.map{|s| s.downcase.gsub(' ', '_').to_sym}
      @tree_view_row = Struct.new *@tree_view_methods
      tree = mk_tree tables
      @tree_view_paths, @tree_view_rows = [], {}
      mk_path tree
      tmp = tree.flatten
      @tree_view_paths.each_with_index do |path, i|
        @tree_view_rows[path] = tmp[i]
      end
      
      titles.each_with_index do |name, i|
        canvas.append_column Gtk::TreeViewColumn.new(name, Gtk::CellRendererText.new, "text" => i)
      end
      @tree_view_store = Gtk::TreeStore.new *Array.new(@tree_view_methods.length){String}
      
      mk_column tree
      canvas.model = @tree_view_store
      
      canvas.signal_connect("cursor-changed") do |s|
        yield @tree_view_rows[s.cursor[0].to_str]
      end if block_given?
    end
    
    def mk_column vals, parent = nil
      vals.each_with_index do |v, i|
        if v.is_a? Array
          mk_column v, parent
        else
          if i.zero?
            parent = @tree_view_store.append parent
            @tree_view_methods.each_with_index{|e, i| parent[i] = eval("v.#{e}").to_s}
          else
            child = @tree_view_store.append parent
            @tree_view_methods.each_with_index{|e, i| child[i] = eval("v.#{e}").to_s}
          end
        end
      end
    end

    def mk_tree tables
      tables.map do |table|
        if table.is_a? Array
          mk_tree table
        else
          return @tree_view_row.new( *tables )
        end
      end
    end
    
    def mk_path tree, path = []
      tree.each_with_index do |t, i|
        if t.is_a? Array
          path.push(path.empty? ? i : (i.zero? ? i : i-1))
          mk_path t, path
          path.pop
        else
          tmp = i.zero? ? path : [path, i-1]
          @tree_view_paths << tmp.flatten.join(':')
        end
      end
    end
  end
end
