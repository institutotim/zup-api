class FixReportOverdueHistoryDups < ActiveRecord::Migration
  def change
    # Get all
    items_with_duplicated_overdue = Reports::ItemHistory.where(kind: 'overdue')
                                      .group(:reports_item_id)
                                      .having('COUNT(*) > 1').count

    puts "Found #{items_with_duplicated_overdue.size} items with duplicated overdue history, deleting..."

    items_with_duplicated_overdue.each do |item_id, _count|
      puts "Deleting reports for report ##{item_id}"
      dups_history_items = Reports::ItemHistory.where(kind: 'overdue',
                                                      reports_item_id: item_id)
                                               .order(id: :asc)

      deleted_count = 0
      dups_history_items.each_with_index do |history_item, i|
        next if i == 0
        history_item.destroy
        deleted_count += 1
      end

      puts "Deleted #{deleted_count} history dups"
    end
  end
end
