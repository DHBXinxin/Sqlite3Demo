//
//  ViewController.m
//  Sqlite3Demo
//
//  Created by Shorigo on 16/6/17.
//  Copyright © 2016年 Shorigo. All rights reserved.
//

#import "ViewController.h"

#import <sqlite3.h>

#define TableName @"TableName"
@interface ViewController ()

@property (nonatomic) sqlite3 *sqlBase;

@property (strong, nonatomic)  NSString *path;

@end

@implementation ViewController
- (void)setupView {
    UIButton *insertOne = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    insertOne.frame = CGRectMake(10, 10, 60, 40);
    [insertOne setTitle:@"插入一" forState:UIControlStateNormal];
    [self.view addSubview:insertOne];
    [insertOne addTarget:self action:@selector(insertOne:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *insertLot = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    insertLot.frame = CGRectMake(10, 45, 60, 40);
    [insertLot setTitle:@"插入多" forState:UIControlStateNormal];
    [insertLot addTarget:self action:@selector(insertLot:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertLot];
    
    UIButton *readSql = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    readSql.frame = CGRectMake(10, 90, 60, 40);
    [readSql setTitle:@"读取" forState:UIControlStateNormal];
    [readSql addTarget:self action:@selector(readSql:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readSql];
    
    UIButton *deleteSql = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteSql.frame = CGRectMake(10, 135, 60, 40);
    [deleteSql setTitle:@"删除一" forState:UIControlStateNormal];
    [deleteSql addTarget:self action:@selector(deleteSql:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteSql];
    
    UIButton *updateSql = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    updateSql.frame = CGRectMake(10, 180, 60, 40);
    [updateSql setTitle:@"更新" forState:UIControlStateNormal];
    [updateSql addTarget:self action:@selector(updateSql:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateSql];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _path = @"/Users/shorigo/Desktop/demo.db";
    
    [self createSql];
    
    [self setupView];
}
#pragma mark - 更新数据
- (void)updateSql:(UIButton *)sender {
    if (![self beginTransaction]) {
        return;
    }
    NSString *ocSql = [NSString stringWithFormat:@"update %@ set 'name'='wang wu' where id =2",TableName];
    const char *sql = [ocSql UTF8String];
    if(sqlite3_exec(_sqlBase, sql, NULL, NULL, NULL)==SQLITE_OK)
    {
        NSLog(@"修改成功");
    }
    if (![self commitTransaction]) {
        return;
    }
}
#pragma mark - 删除一条数据
- (void)deleteSql:(UIButton *)sender {
    if (![self beginTransaction]) {
        return;
    }
    NSString *ocSql = [NSString stringWithFormat:@"delete from %@ where id=2",TableName];
    const char *sql = [ocSql UTF8String];
    if(sqlite3_exec(_sqlBase, sql, NULL, NULL, NULL)==SQLITE_OK)
    {
        NSLog(@"删除成功");
    }
    if (![self commitTransaction]) {
        return;
    }
}
#pragma mark - 读取数据
- (void)readSql:(UIButton *)sender {
    if (![self beginTransaction]) {
        return;
    }
    sqlite3_stmt *stmt = NULL;
    NSString *ocSql = [NSString stringWithFormat:@"select * from %@",TableName];
    const char *sql = [ocSql UTF8String];
    if (sqlite3_prepare(_sqlBase, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"数据库prepareStatment失败:%@", ocSql);
        return;
    }
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int tableId = (int)sqlite3_column_int(stmt, 0);
        char *name = (char *)sqlite3_column_text(stmt, 1);
        NSLog(@"id:%iname:%s",tableId, name);
        int count = sqlite3_column_count(stmt);//获取表结构有多少列
        const char *key = sqlite3_column_name(stmt,1);//获取表结构此列的抬头
        NSLog(@"count:%ikey:%s",count, key);
        
    }
    sqlite3_finalize(stmt);
    if (![self commitTransaction]) {
        return;
    }
}
#pragma mark - 插入多条数据
- (void)insertLot:(UIButton *)sender {
    if (![self beginTransaction]) {
        return;
    }
    NSString *ocSql = [NSString stringWithFormat:@"insert into %@ ('name') values(?)",TableName];
    const char *sql = [ocSql UTF8String];
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare(_sqlBase, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"数据库prepareStatment失败:%@", ocSql);
        return;
    }
    NSArray *names = @[@"li\'", @"wang", @"zhang", @"zhao"];
    for (NSString *name in names) {
        int bindPos = 1;//绑定位置从1开始、比如有两个？的时候
        if (sqlite3_bind_text(stmt, bindPos++, [name UTF8String], -1, SQLITE_STATIC) != SQLITE_OK) {//其中-1表示全部存储
            NSLog(@"绑定失败:%@", [[NSString alloc] initWithUTF8String:sqlite3_errmsg(_sqlBase)]);
            continue;
        }
//        if (sqlite3_bind_int(stmt , (bindPos++),  [name intValue]) != SQLITE_OK) {
//            NSLog(@"绑定失败:%@", [[NSString alloc] initWithUTF8String:sqlite3_errmsg(db)]);
//            continue;
//        }
        if (sqlite3_step(stmt) == SQLITE_DONE) {
            NSLog(@"执行");
        }
        sqlite3_reset(stmt);
    }
    sqlite3_finalize(stmt);
    if (![self commitTransaction]) {
        return;
    }
}
#pragma mark - 插入一条数据
- (void)insertOne:(UIButton *)sender {
    if (![self beginTransaction]) {
        return;
    }
    NSString *ocSql = [NSString stringWithFormat:@"insert into %@ ('name') values('zhang san')",TableName];
    const char* sql = [ocSql UTF8String];
    if(sqlite3_exec(_sqlBase, sql, NULL, NULL, NULL)==SQLITE_OK)
    {
        NSLog(@"插入成功");
    }
    if (![self commitTransaction]) {
        return;
    }
}
#pragma mark - 创建数据库
- (void)createSql {
    if (![self beginTransaction]) {
        return;
    }
    NSString *ocSql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,name text)",TableName];
    const char *sql = [ocSql UTF8String];
    if (sqlite3_exec(_sqlBase, sql, NULL, NULL, NULL) == SQLITE_OK) {
        NSLog(@"创建成功");
    }
    if (![self commitTransaction]) {
        return;
    }
}
#pragma mark - 通用方法
- (BOOL)beginTransaction {
    if (sqlite3_open([_path UTF8String], &_sqlBase) == SQLITE_OK) {
        return YES;
    }
    NSLog(@"打开数据库失败");
    return YES;
}
- (BOOL)commitTransaction {
    if (sqlite3_close(_sqlBase) == SQLITE_OK) {
        return YES;
    }
    NSLog(@"关闭数据库失败");
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
