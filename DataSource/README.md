### 关于
继承自YAArrayDataSource的子类对象可以作为UITableView或者UICollectionView的数据源.

### 使用

#### 声明并定义UITableViewCell的回调
    void (^cellHandler)(YATableViewCell *cell, YAModel *model) = ^(YATableViewCell *cell, YAModle *model){
        cell.model = model;
    };
    
#### 将数据源声明为控制器的强引属性，设置UITableView的dataSource

    @property (nonatomic, strong) YAArrayDataSource *arrayDataSource;
    
    self.arrayDataSource = [[YAArrayDataSource alloc] initWithDataArray:self.dataArray cellIdentifier:YATableViewCellIdentifier configureCellHandler:cellHandler];
    self.tableView.dataSource = self.arrayDataSource;

### 扩展
#### 移动操作

    // Data manipulation - move support
    - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
        return YES;
    }
    
    - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
        // exchange object in data array.
        [self.dataArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        [tableView reloadData];
    }

### 插入删除操作

    // Data manipulation - insert and delete support
    - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self.dataArray removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
            NSLog(@"删除");
        }
        
        if (editingStyle == UITableViewCellEditingStyleInsert) {
            NSLog(@"插入");
        }
    }


