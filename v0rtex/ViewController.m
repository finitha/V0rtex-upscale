//
//  ViewController.m
//  v0rtex
//
//  Created by Sticktron on 2017-12-07.
//  Copyright © 2017 Sticktron. All rights reserved.
//

#import "ViewController.h"

#include "v0rtex.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (weak, nonatomic) IBOutlet UIButton *sploitButton;
@end



@implementation ViewController
    @synthesize widthtf,heighttf;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.sploitButton.layer.cornerRadius = 6;
    self.outputView.layer.cornerRadius = 6;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

char* bundle_path() {
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
    int len = 4096;
    char* path = malloc(len);
    
    CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8*)path, len);
    
    return path;
}

- (IBAction)runSploitButton:(UIButton *)sender {
    
    // Run v0rtex
    
    
    self.outputView.text = [self.outputView.text stringByAppendingString:@"\n > running exploit... \n"];

    task_t tfp0 = MACH_PORT_NULL;
    kptr_t kslide = 0;
    
    kern_return_t v0rtex(task_t *tfp0, kptr_t *kslide);
    kern_return_t ret = v0rtex(&tfp0, &kslide);
    
    if (ret != KERN_SUCCESS) {
        self.outputView.text = [self.outputView.text stringByAppendingString:@"ERROR: exploit failed \n"];
        return;
    }
    
    self.outputView.text = [self.outputView.text stringByAppendingString:@"exploit succeeded! \n"];
    
    
    // Write a test file
    
    self.outputView.text = [self.outputView.text stringByAppendingString:@"writing test file... \n"];
    
    extern kern_return_t mach_vm_read_overwrite(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t data, mach_vm_size_t *outsize);
    uint32_t magic = 0;
    mach_vm_size_t sz = sizeof(magic);
    ret = mach_vm_read_overwrite(tfp0, 0xfffffff007004000 + kslide, sizeof(magic), (mach_vm_address_t)&magic, &sz);
    LOG("mach_vm_read_overwrite: %x, %s", magic, mach_error_string(ret));
    
    FILE *f = fopen("/var/mobile/test.txt", "w");
    LOG("file: %p", f);
    if (f == 0) {
        self.outputView.text = [self.outputView.text stringByAppendingString:@"ERROR: failed to write test file \n"];
        return;
    } else {
        self.outputView.text = [self.outputView.text stringByAppendingString:@"Wrote test file! \n"];
        fclose(f);
        remove("/var/mobile/test.txt");
        self.outputView.text = [self.outputView.text stringByAppendingString:@"Deleted test file! \n"];
        
    }
    
    
    self.outputView.text = [self.outputView.text stringByAppendingString:[NSString stringWithFormat:@"/var/mobile/test.txt (%p) \n", f]];
    
    
    // Next steps ???
    
    char ch;
    FILE *source, *target;
    
    char* path;
    
    asprintf(&path, "%s/com.apple.iokit.IOMobileGraphicsFamily.plist", bundle_path());
    
    // Setting custom width/height;
    
    char *cwidth, *cheight;
    
    if (widthtf.text.length==0||heighttf.text.length==0){
        LOG("NO CUSTOM WIDTH WAS FOUND, USING DEFAULT");
        source = fopen(path, "r");
        
    } else {
        /*Doesn't work yet
         TODO:
         get data from textfields - done;
         generating plist - done;
         
         testing it and commenting return
         */
        cwidth =  [widthtf.text UTF8String];
        cheight = [heighttf.text UTF8String];
        source = fopen("/var/mobile/Library/Preferences/dummy.plist","w");
        fprintf(source,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n<key>\ncanvas_height</key>\n<integer>%s</integer>\n<key>canvas_width</key>\n<integer>%s</integer>\n</dict>\n</plist>",cheight,cwidth);
        fclose(source);
        NSString *customwidthheight=[NSString stringWithFormat:@"%s",cwidth];
        self.outputView.text = [self.outputView.text stringByAppendingString:customwidthheight];
        self.outputView.text = [self.outputView.text stringByAppendingString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n<key>\ncanvas_height</key>\n<integer>%s</integer>\n<key>canvas_width</key>\n<integer>%s</integer>\n</dict>\n</plist>"];
        /*comment me and risk it */
        return;
    }
    
    
    target = fopen("/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", "w");
    
    while( ( ch = fgetc(source) ) != EOF )
        fputc(ch, target);
    
    self.outputView.text = [self.outputView.text stringByAppendingString:@"Resolution changed, please reboot.\n"];
    
    fclose(source);
    fclose(target);
    
    
    // Done.
    self.outputView.text = [self.outputView.text stringByAppendingString:@"\n"];
    self.outputView.text = [self.outputView.text stringByAppendingString:@"done. \n"];
}

    - (IBAction)widthtf:(UITextField *)sender {
    }
    
- (IBAction)heighttf:(UITextField *)sender {
}
    @end
