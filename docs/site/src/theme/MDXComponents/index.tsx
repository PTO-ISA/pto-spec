import React, {type ComponentProps} from 'react';
import OriginalMDXComponents from '@theme-original/MDXComponents';

function AccessibleTable(props: ComponentProps<'table'>) {
  return <table {...props} tabIndex={props.tabIndex ?? 0} />;
}

export default {
  ...OriginalMDXComponents,
  table: AccessibleTable,
};
